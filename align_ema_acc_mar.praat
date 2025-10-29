nocheck select all
nocheck Remove

## STEP 1: align the EMA sweeps with the acc recording
## The sweeps are 'local' in the session, the acc recording is 'global'
## So first align the sounds of all relevant sweeps with the sound from the acc recording
## This gives a text grid with the sweep intervals relative to the acc recording

speaker$ = "LLB"

if speaker$ = "LLB"
	accFile$ ="/home/johanf/data/donnaalign/EMA_MARRYS_ACCelrometerRecordings_Feb2024/Ben_feb2_2024.WAV"
	tgFile$ = "/home/johanf/data/donnaalign/time-align/Ben_feb2_2024_ch2_1000.TextGrid"
	marFile$ = "/home/johanf/data/donnaalign/LLB_Cat_20242210512_Marrys.wav"
	column = 73
	firstfile = 2
	lastfile = 56
	last_plausible_time = 842
	# determined by best pre-dtw correlation
	det_shift_time = 34.58
endif
if speaker$ = "PGU"
	accFile$ ="/home/johanf/data/donnaalign/EMA_MARRYS_ACCelrometerRecordings_Feb2024/Donna_Feb6_2024_850.WAV"
	tgFile$ = "/home/johanf/data/donnaalign/time-align/Donna_Feb6_2024_850_1000.TextGrid"
	marFile$ = "/home/johanf/data/donnaalign/PGU_cat_202426162218_Marrys.wav"
	column = 108
	firstfile = 3
	lastfile = 47
	last_plausible_time = 760
	det_shift_time = 7.89
endif
if speaker$ = "BNY"
	accFile$ = "/home/johanf/data/donnaalign/EMA_MARRYS_ACCelrometerRecordings_Feb2024/Kristi_Feb7_2024.WAV"
	tgFile$ = "/home/johanf/data/donnaalign/time-align/Kristi_Feb7_2024_1000.TextGrid"
	marFile$ = "/home/johanf/data/donnaalign/BNY_cat_20242712148_Marrys.wav"
	column = 108
	firstfile = 3
	lastfile = 60
	last_plausible_time = 1300
	# this was hard to find - had to manually review and find this
	det_shift_time = 246.63
endif
if speaker$ = "TRH"
	accFile$ = "/home/johanf/data/donnaalign/EMA_MARRYS_ACCelrometerRecordings_Feb2024/Alicia_Feb7_2024_2.WAV"
	tgFile$ = "/home/johanf/data/donnaalign/time-align/Alicia_Feb7_2024_2.TextGrid"
	marFile$ = "/home/johanf/data/donnaalign/TRH_cat_202427144824_Marrys.wav"
	column = 101
	firstfile = 2
	lastfile = 57
	last_plausible_time = 1300
	det_shift_time = -15.23
endif

# set to 10000 for real. to 1000 for quick - actually 10000 gives memory troubles, so set to 1000 anyway
sf_for_cor = 1000

s1= Read from file: accFile$
s2 = Extract one channel: 2
s3 = Resample: sf_for_cor, 50
s3 = selected("Sound")
tg1 = To TextGrid: "sweeps", ""

clearinfo
#pauseScript: "Hello"


myDirectory$ = "/home/johanf/data/donnaalign" + "/" + speaker$

wavfolder$ = myDirectory$+"/wav"
emafolder$ = myDirectory$+"/pos"
marfolder$ = myDirectory$+"/mar2"
createFolder: marfolder$

wavstrings = Create Strings as file list: "list", wavfolder$ + "/*.wav"
numberOfFiles = Get number of strings

extract_for_dtw = 1

for ifile from firstfile to lastfile
        selectObject: wavstrings
        wavFileName$ = Get string: ifile

		if extract_for_dtw > 0
		sweepName$ = left$(wavFileName$,4)
		sweepnumber = number(sweepName$)
		emaFileName$ = replace$(wavFileName$, "wav", "txt",0)

		ema_table = Read from file: emafolder$ + "/" + emaFileName$
		ema_matrix = Down to Matrix
		ema_matrix2 = Transpose
		ema_sound = To Sound (slice): column
		Scale times to: 0, 1
		Override sampling frequency: 250
		Scale peak: 0.99
		Save as WAV file: marfolder$ + "/" + sweepName$ + "_emaaswav.wav"
		select 'ema_table'
		plus 'ema_matrix'
		plus 'ema_matrix2'
		plus 'ema_sound'
		Remove
		endif

        #pauseScript: "The next file will be ", wavFileName$
        w'ifile' = Read from file: wavfolder$ + "/" + wavFileName$
        s4 = Resample: sf_for_cor, 50
        dur = Get total duration
        plusObject: s3
        s5 = Cross-correlate: "peak 0.99", "zero"
        tm = Get time of maximum: 0, 0, "sinc70"
        swst = tm * -1
        swen = swst + dur
        selectObject: tg1
        Insert boundary: 1, swst
        nin = Get low interval at time: 1, swen
        Insert boundary: 1, swen
        iname$ = "sweep_" + wavFileName$
        Set interval text: 1, nin, iname$
        appendInfoLine: ifile, tab$, tm, tab$, nin, tab$, swst, tab$, swen
        selectObject: w'ifile'
        plusObject: s4
        plusObject: s5
        Remove
endfor
# save the TextGrid
select 'tg1'
Save as text file: tgFile$


## STEP 2: align the acc recording with the Marrys recording
select 's2'
s6 = Resample: 2000, 50

s7= Read from file: marFile$
s8 = Extract one channel: 2

plusObject: s6
s9 = Cross-correlate: "peak 0.99", "zero"

# this is where we look for a peak in the cc
pauseScript: "Look for a peak in the cc. Then select the Marrys sound and shift its start time"
# check that it is plausible with TextGrid file

# shift times to what you determine here
#select 's8'
#Shift times to: "start time", det_shift_time

## STEP 3: extract and save the portions that are marrys-aligned-to-acc-aligned-to-ema 

# input
#	a Sound with the Marrys data, scaled and shifted
#   251023: seems we can't scale, it is too nonlinear
#   shift we get from align_marrys_and_acc
#	a TextGrid with the intervals of the sweeps

## we can run from here if we just want to test a shift time
## just set variables correct :)
## comment out following 6 lines and the 'Shift times...' below
#s8 = selected("Sound")
#tg1 = selected("TextGrid")
#last_plausible_time = 760
#speaker$ = "PGU"
#myDirectory$ = "/home/johanf/data/donnaalign" + "/" + speaker$
#marfolder$ = myDirectory$+"/mar2"


select 's8'
#Shift times to: "start time", 7.89
s9 = Resample: 250, 50
s1 = selected("Sound")

selectObject: tg1

niv = Get number of intervals: 1
for tiv from 1 to niv
	selectObject: tg1
	lab$ = Get label of interval: 1, tiv
	if lab$ != ""
		st = Get start time of interval: 1, tiv
		en = Get end time of interval: 1, tiv
		# this is speaker dep!!! - basically look in the MARRYS file and count
		if en < last_plausible_time
			n1$ = replace$(lab$,"sweep_", "", 0)
			n2$ = replace$(n1$, ".wav", "", 0)
			selectObject: s1	
			s2 = Extract part: st, en, "rectangular", 1, "no"
			fileName$ = marfolder$ + "/" + n2$ + ".wav"
			appendInfoLine: "Saving", fileName$
			Save as WAV file: fileName$
			Remove
		endif
	endif
endfor

# in shell: mv LLBalign LLB/marX

# now navigate to the mar2 dir and run 

# python ../../time-align/dtw_batch_align_metrics.py --from XXXX --to XXXX --dir . --fs_expect 250 --detrend --zscore --sakoe_band_s 0.5 --use_derivative_cost --trim_tol_samp 20 --skip_missing --roi 2.5:7.5
# awk -F, '{ printf "%s %.3f %.3f\n", $1, $2, $8 }' dtw_batch_metrics.csv




