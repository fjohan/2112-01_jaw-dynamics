#!/usr/bin/env python3
# dtw_batch_align_metrics.py
import argparse, os
import numpy as np
import soundfile as sf
import matplotlib.pyplot as plt
import librosa
from scipy.signal import detrend
from typing import Tuple, Dict, List, Optional

# ---------- helpers ----------
def zscore(x):
    x = x.astype(float)
    return (x - np.nanmean(x)) / (np.nanstd(x) + 1e-12)

def load_wav_mono(path: str):
    y, sr = sf.read(path)
    y = np.squeeze(y).astype(float)
    return y, sr

def save_float_wav(path: str, y, sr: int):
    y = np.asarray(y)
    peak = np.max(np.abs(y)) if y.size else 0.0
    if np.isfinite(peak) and peak > 0:
        y = (0.99/peak) * y
    sf.write(path, y.astype(np.float32), sr, subtype="FLOAT")

def trim_small_len_diff(y_ref: np.ndarray, y_mov: np.ndarray, tol: int) -> Tuple[np.ndarray, np.ndarray, bool]:
    """If |len(ref)-len(mov)| ≤ tol, trim the longer at the END to match the shorter."""
    nR, nM = len(y_ref), len(y_mov)
    diff = nR - nM
    if abs(diff) <= tol and diff != 0:
        n_min = min(nR, nM)
        if diff > 0:   # ref longer
            return y_ref[:n_min], y_mov, True
        else:          # mov longer
            return y_ref, y_mov[:n_min], True
    return y_ref, y_mov, False

def build_warp_map_from_path(wp: np.ndarray, n_ref: int, n_mov: int) -> np.ndarray:
    i_ref = wp[:, 0].astype(int)
    j_mov = wp[:, 1].astype(int)
    uniq_i, _ = np.unique(i_ref, return_index=True)
    # median j per i, then interp to full grid
    j_for_uniq_i = []
    p = 0
    for u in uniq_i:
        s = p
        while p < len(i_ref) and i_ref[p] == u:
            p += 1
        j_for_uniq_i.append(int(np.median(j_mov[s:p])))
    j_for_uniq_i = np.asarray(j_for_uniq_i, dtype=float)
    ref_grid = np.arange(n_ref, dtype=float)
    warp_map = np.interp(ref_grid, uniq_i.astype(float), j_for_uniq_i)
    warp_map = np.maximum.accumulate(warp_map)
    warp_map = np.clip(warp_map, 0, n_mov - 1)
    return warp_map

def auto_roi(n: int, keep_frac: float = 0.8) -> Tuple[int, int]:
    keep = int(max(1, round(n * keep_frac)))
    start = max(0, (n - keep) // 2)
    end = min(n, start + keep)
    return start, max(end, start + 1)

def pearsonr(a, b):
    a = a.astype(float); b = b.astype(float)
    a = a - np.mean(a); b = b - np.mean(b)
    denom = (np.linalg.norm(a) * np.linalg.norm(b)) + 1e-12
    return float(np.dot(a, b) / denom)

def nrmse(ref, x):
    err = ref - x
    return float(np.sqrt(np.mean(err**2)) / (np.std(ref) + 1e-12))

def max_xcorr_and_lag(a, b):
    a = a - np.mean(a); b = b - np.mean(b)
    c = np.correlate(a, b, mode='full')
    lag = np.argmax(c) - (len(b) - 1)
    denom = (np.linalg.norm(a) * np.linalg.norm(b)) + 1e-12
    r_peak = float(c[np.argmax(c)] / denom)
    return r_peak, int(lag)

def compute_metrics(ref, mov, roi_slice, sr: int, prefix: str) -> Dict[str, float]:
    r = ref[roi_slice]; m = mov[roi_slice]
    out = {
        f"pearson_raw_{prefix}": pearsonr(r, m),
        f"pearson_z_{prefix}":   pearsonr(zscore(r), zscore(m)),
        f"nrmse_{prefix}":       nrmse(r, m),
    }
    r_peak, lag = max_xcorr_and_lag(r, m)
    out[f"xcorr_peak_{prefix}"] = r_peak
    out[f"xcorr_lag_samples_{prefix}"] = lag
    out[f"xcorr_lag_seconds_{prefix}"] = lag / float(sr)
    return out

def dtw_align_and_metrics(
    ref_wav: str,
    mov_wav: str,
    out_prefix: str,
    aligned_stereo_path: str,
    aligned_mono_path: Optional[str],
    fs_expect: Optional[int],
    sakoe_band_s: float,
    use_derivative_cost: bool,
    detrend_cost: bool,
    zscore_cost: bool,
    roi_seconds: Optional[Tuple[float, float]],
    trim_tol_samp: int
) -> Dict[str, float]:
    # Load
    y_ref, sr_ref = load_wav_mono(ref_wav)
    y_mov, sr_mov = load_wav_mono(mov_wav)
    if fs_expect is not None and (sr_ref != fs_expect or sr_mov != fs_expect):
        raise ValueError(f"SR mismatch (expected {fs_expect}): {ref_wav}={sr_ref}, {mov_wav}={sr_mov}")

    # Optional tiny-length trim
    y_ref, y_mov, trimmed = trim_small_len_diff(y_ref, y_mov, trim_tol_samp)
    if trimmed:
        print(f"  • Trimmed tiny length mismatch → new length = {len(y_ref)} samples")

    # Prep copies for DTW cost
    yr = y_ref.copy(); ym = y_mov.copy()
    if detrend_cost:
        yr = detrend(yr, type="linear"); ym = detrend(ym, type="linear")
    if zscore_cost:
        yr = zscore(yr); ym = zscore(ym)

    # Features
    if use_derivative_cost:
        def deriv(x):
            d = np.zeros_like(x)
            d[1:-1] = 0.5*(x[2:] - x[:-2])
            d[0] = d[1]; d[-1] = d[-2]
            return d
        F_ref = np.vstack([yr, deriv(yr)])
        F_mov = np.vstack([ym, deriv(ym)])
    else:
        F_ref = yr[None, :]
        F_mov = ym[None, :]

    # DTW
    radius = int(sakoe_band_s * sr_ref)
    D, wp = librosa.sequence.dtw(
        X=F_ref, Y=F_mov,
        metric="euclidean",
        global_constraints=True,
        band_rad=radius,
        backtrack=True,
    )
    wp = wp[::-1]

    # Warp map and aligned signal
    warp_map = build_warp_map_from_path(wp, len(y_ref), len(y_mov))
    t_mov = np.arange(len(y_mov), dtype=float)
    y_mov_aligned = np.interp(warp_map, t_mov, y_mov)

    # Save audio
    pair = np.column_stack([y_ref.astype(np.float32), y_mov.astype(np.float32), y_mov_aligned.astype(np.float32)])
    save_float_wav(aligned_stereo_path, pair, sr_ref)
    if aligned_mono_path:
        save_float_wav(aligned_mono_path, y_mov_aligned, sr_ref)

    # Diagnostics lite
    np.savetxt(f"{out_prefix}_warp_path.csv", wp, fmt="%d", delimiter=",",
               header="ref_idx,mov_idx", comments="")
    np.savetxt(f"{out_prefix}_warp_map.csv", warp_map, fmt="%.6f", delimiter=",",
               header="ref_index -> mov_index (float)", comments="")
    fig, ax = plt.subplots(figsize=(6.5, 5.5), dpi=130)
    im = ax.imshow(D.T, origin="lower", aspect="auto", cmap="magma")
    ax.plot(wp[:, 0], wp[:, 1], color="cyan", linewidth=1.0, alpha=0.9, label="DTW path")
    ax.set_xlabel("Reference index"); ax.set_ylabel("Moving index")
    ax.set_title("DTW accumulated cost (transposed) + path")
    ax.legend(loc="upper right")
    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04, label="Accumulated cost")
    fig.tight_layout(); fig.savefig(f"{out_prefix}_cost_path.png"); plt.close(fig)

    # ROI for metrics
    if roi_seconds is not None:
        t0s, t1s = roi_seconds
        r0 = int(round(t0s * sr_ref)); r1 = int(round(t1s * sr_ref))
        r0 = max(0, r0); r1 = min(len(y_ref), r1)
        if r1 <= r0: r0, r1 = auto_roi(len(y_ref))
        ROI = slice(r0, r1, 1)
    else:
        ROI = slice(*auto_roi(len(y_ref)))

    # Metrics before & after
    m_before = compute_metrics(y_ref, y_mov, ROI, sr_ref, prefix="before")
    m_after  = compute_metrics(y_ref, y_mov_aligned, ROI, sr_ref, prefix="after")

    # Overlay/errors plot
    t = np.arange(len(y_ref)) / sr_ref
    fig2, ax2 = plt.subplots(2, 1, figsize=(9.5, 6), dpi=130, sharex=True)
    ax2[0].plot(t, y_ref, label="Reference", linewidth=1.1)
    ax2[0].plot(t, y_mov, label="Moving (before)", alpha=0.7, linewidth=1.0)
    ax2[0].plot(t, y_mov_aligned, label="Aligned (after)", alpha=0.9, linewidth=1.0)
    ax2[0].legend(loc="upper right"); ax2[0].set_ylabel("Amplitude")
    ax2[0].set_title("Before/After alignment")
    ax2[1].plot(t, y_ref - y_mov, label="Error before", alpha=0.7, linewidth=1.0)
    ax2[1].plot(t, y_ref - y_mov_aligned, label="Error after", alpha=0.9, linewidth=1.0)
    ax2[1].legend(loc="upper right"); ax2[1].set_xlabel("Time (s)"); ax2[1].set_ylabel("Ref − Signal")
    fig2.tight_layout(); fig2.savefig(f"{out_prefix}_overlay_errors.png"); plt.close(fig2)

    # Merge dicts for CSV row
    rec = {}
    rec.update(m_before)
    rec.update(m_after)
    return rec

# ---------- batch driver ----------
def main():
    #ap = argparse.ArgumentParser(description="Batch DTW alignment with before/after metrics and tiny-length trimming.")

    ap = argparse.ArgumentParser(
        description="Batch DTW alignment with before/after metrics and tiny-length trimming.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    ap.add_argument("--from", dest="start", type=int, required=True, help="Start number (inclusive), e.g., 2")
    ap.add_argument("--to",   dest="end",   type=int, required=True, help="End number (inclusive), e.g., 25")
    ap.add_argument("--width", type=int, default=4, help="Zero-pad width (default 4; 0002, 0003, ...)")
    ap.add_argument("--dir", default=".", help="Directory containing WAVs (default: current)")
    ap.add_argument("--fs_expect", type=int, default=250, help="Expected sample rate to enforce (default 250)")
    ap.add_argument("--sakoe_band_s", type=float, default=0.5, help="Sakoe–Chiba band radius in seconds")
    ap.add_argument("--use_derivative_cost", action="store_true", help="Use [value, velocity] features for DTW")
    ap.add_argument("--detrend_cost", action="store_true", help="Detrend signals for DTW cost")
    ap.add_argument("--zscore_cost", action="store_true", help="Z-score signals for DTW cost")
    ap.add_argument("--roi", type=str, default=None, help="Metrics ROI in seconds 'start:end' (default: central 80%%)")
    ap.add_argument("--trim_tol_samp", type=int, default=2, help="If |len(ref)-len(mov)| ≤ tol, trim longer at end")
    ap.add_argument("--skip_missing", action="store_true", help="Skip IDs with missing files instead of erroring")
    ap.add_argument("--metrics_csv", default="dtw_batch_metrics.csv", help="Output CSV (one row per ID + MEAN)")
    args = ap.parse_args()

    roi_seconds = None
    if args.roi:
        try:
            a, b = [float(x) for x in args.roi.split(":")]
            roi_seconds = (a, b)
        except Exception:
            raise ValueError("ROI must be 'start:end' in seconds, e.g., 1.0:9.0")

    # CSV header with both BEFORE and AFTER columns
    header = [
        "id",
        "pearson_raw_before","pearson_z_before","nrmse_before",
        "xcorr_peak_before","xcorr_lag_samples_before","xcorr_lag_seconds_before",
        "pearson_raw_after","pearson_z_after","nrmse_after",
        "xcorr_peak_after","xcorr_lag_samples_after","xcorr_lag_seconds_after",
    ]

    rows: List[List[object]] = []
    ids_done: List[str] = []

    for n in range(args.start, args.end + 1):
        id_str = f"{n:0{args.width}d}"
        ref_path = os.path.join(args.dir, f"{id_str}_emaaswav.wav")
        mov_path = os.path.join(args.dir, f"{id_str}.wav")
        out_prefix = os.path.join(args.dir, f"dtw_{id_str}")
        pair_out = os.path.join(args.dir, f"{id_str}_aligned.wav")           # stereo [ref, aligned]
        mono_out = os.path.join(args.dir, f"{id_str}_aligned_mono.wav")      # optional mono aligned

        if not os.path.exists(ref_path) or not os.path.exists(mov_path):
            msg = []
            if not os.path.exists(ref_path): msg.append(ref_path)
            if not os.path.exists(mov_path): msg.append(mov_path)
            print(f"[{id_str}] Missing: {', '.join(msg)}")
            if args.skip_missing:
                continue
            else:
                raise FileNotFoundError(f"Required file(s) missing for {id_str}")
        try:
            print(f"[{id_str}] Processing…")
            rec = dtw_align_and_metrics(
                ref_wav=ref_path,
                mov_wav=mov_path,
                out_prefix=out_prefix,
                aligned_stereo_path=pair_out,
                aligned_mono_path=mono_out,
                fs_expect=args.fs_expect,
                sakoe_band_s=args.sakoe_band_s,
                use_derivative_cost=args.use_derivative_cost,
                detrend_cost=args.detrend_cost,
                zscore_cost=args.zscore_cost,
                roi_seconds=roi_seconds,
                trim_tol_samp=args.trim_tol_samp
            )
            row = [id_str] + [rec[k] for k in header[1:]]
            rows.append(row)
            ids_done.append(id_str)
            print(f"[{id_str}] OK  z-r before→after: {rec['pearson_z_before']:.3f} → {rec['pearson_z_after']:.3f} | NRMSE {rec['nrmse_before']:.3f} → {rec['nrmse_after']:.3f}")
        except Exception as e:
            print(f"[{id_str}] ERROR: {e}")
            if not args.skip_missing:
                raise

    # Save CSV (one row per ID + MEAN)
    arr = np.array(rows, dtype=object)
    if arr.size:
        num = arr[:, 1:].astype(float)  # all metric columns
        mean_vals = np.mean(num, axis=0)
        mean_row = ["MEAN"] + [float(x) for x in mean_vals.tolist()]
        out_with_mean = np.vstack([arr, np.array(mean_row, dtype=object)])
    else:
        out_with_mean = np.array([header], dtype=object)

    np.savetxt(
        args.metrics_csv,
        out_with_mean,
        fmt="%s",
        delimiter=",",
        header=",".join(header),
        comments=""
    )

    print("\nDone.")
    print(f"Processed IDs: {', '.join(ids_done) if ids_done else '(none)'}")
    print(f"Metrics CSV: {args.metrics_csv}")

if __name__ == "__main__":
    main()


