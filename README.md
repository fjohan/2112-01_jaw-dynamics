# 2112-01_jaw-dynamics

Scripts and data for exploring jaw articulation

## Files

| File | Description |
|------|--------------|
| `MIN_MAX_AL5.tsv` | Table of per-token jaw opening measures (minimum/maximum position, metadata) used by R scripts. |
| `hyp1_w_plots.R` | Computes statistics and generates plots for focus-related measurements of jaw lowering. |
| `hyp2_w_plots.R` | Tests whether the focused word shows the largest jaw lowering in the utterance; includes plotting. |
| `align_ema_acc_mar.praat` | Praat script aligning EMA sweep audio to the accelerometer, and the accelerometer to MARRYS recordings (via cross-correlation and manual adjustment). |
| `view_and_calc_JASAexpr.praat` | Praat helper script to visualize EMA tracks and extract per-word minima (maximum jaw opening); supports quality control of misreads and repetitions. |
| `dtw_batch_align_metrics.py` | Python script performing dynamic time warping (DTW) alignment of MARRYS and EMA data, and computing per-sweep EMA–MARRYS correlation metrics. |

---

*Repository: [`fjohan/2112-01_jaw-dynamics`](https://github.com/fjohan/2112-01_jaw-dynamics)*

