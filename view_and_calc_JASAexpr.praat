nocheck select all
nocheck Remove

## set speaker and folder before running (THE or AB0)
#speaker$ = "PGU"
#wordset = 1

# Both: PGU BNY KVM TRH LLB
# 1: YSD
# 2: THE AB0
@setConf: "LLB",1

procedure setConf: inSpea$, inWordset 

speaker$ = inSpea$
wordset = inWordset

if speaker$ == "PGU"
	column = 108
	if wordset == 1
		firstfile = 3
		lastfile = 27
		wordLabels$# = { "cat", "sat", "rat", "hat" }
		blacklist# = { -1 }
	endif
	if wordset == 2
		firstfile = 28
		lastfile = 47
		wordLabels$# = { "fat", "cat", "sat", "matt" }
		blacklist# = { 31 }
	endif
endif

if speaker$ == "BNY"
	column = 108
	if wordset == 1
		firstfile = 3
		lastfile = 28
		wordLabels$# = { "cat", "sat", "rat", "hat" }
		blacklist# = { -1 }
	endif
	if wordset == 2
		firstfile = 29
		lastfile = 60
		wordLabels$# = { "fat", "cat", "sat", "matt" }
		blacklist# = { -1 }
	endif
endif

if speaker$ == "KVM"
	column = 45
	if wordset == 1
		firstfile = 2
		lastfile = 26
		wordLabels$# = { "cat", "sat", "rat", "hat" }
		blacklist# = { 9, 17, 18, 19, 24 }
	endif
	if wordset == 2
		firstfile = 27
		lastfile = 56
		wordLabels$# = { "fat", "cat", "sat", "mat" }
		blacklist# = { -1 }
	endif
endif

if speaker$ == "TRH"
	column = 101
	if wordset == 1
		firstfile = 2
		lastfile = 26
		wordLabels$# = { "cat", "sat", "rat", "hat" }
		blacklist# = { 7, 18, 24 }
	endif
	if wordset == 2
		firstfile = 27
		lastfile = 57
		wordLabels$# = { "fat", "cat", "sat", "matt" }
		blacklist# = { 27, 48, 54 }
	endif
endif

if speaker$ == "LLB"
	column = 73
	if wordset == 1
		firstfile = 2
		lastfile = 26
		wordLabels$# = { "cat", "sat", "rat", "hat" }
		blacklist# = { -1 }
	endif
	if wordset == 2
		firstfile = 27
		lastfile = 56
		wordLabels$# = { "fat", "cat", "sat", "matt" }
		blacklist# = { 28 }
	endif
endif

if speaker$ == "YSD"
	column = 108
	if wordset == 1
		firstfile = 2
		lastfile = 32
		wordLabels$# = { "cat", "sat", "rat", "hat" }
	endif
	# YSD only has 1
	if wordset == 2
		firstfile = 0
		lastfile = 0
		wordLabels$# = { "fat", "cat", "sat", "matt" }
	endif
endif

if speaker$ == "THE"
	column = 59
	# THE only has 2
	if wordset == 1
		firstfile = 0
		lastfile = 0
		wordLabels$# = { "cat", "sat", "rat", "hat" }
	endif
	# YSD only has 1
	if wordset == 2
		firstfile = 5
		lastfile = 33
		wordLabels$# = { "fat", "cat", "sat", "matt" }
	endif
endif

if speaker$ == "AB0"
	column = 80
	# AB0 only has 2
	if wordset == 1
		firstfile = 0
		lastfile = 0
		wordLabels$# = { "cat", "sat", "rat", "hat" }
	endif
	# YSD only has 1
	if wordset == 2
		firstfile = 9
		lastfile = 37
		wordLabels$# = { "fat", "cat", "sat", "matt" }
	endif
endif

endproc

if wordset == 1
	queryLabels$# = { "Q5", "Q2", "Q3", "Q4", "Q1" }
	elicits# = {0,2,3,4,1}
endif
if wordset == 2
	queryLabels$# = { "Q2", "Q3", "Q4", "Q5", "Q1" }
	#elicits$# = { "Q5", "Q1", "Q2", "Q3", "Q4", "Q4" }
	elicits# = {0,1,2,3,4,4}
endif

# linux/mac-style
myDirectory$ = "/home/johanf/data/donnaalign" + "/" + speaker$
# windows-style
#myDirectory$ = "C:/Users/Frid/Documents/JF_Work/FONM23" + "/" + speaker$  + "/" + speaker$

# set the EMA column you want to view
# each channel has 7 columns: (x,y,z,phi,delta,rms,extra)

### set at top now column = 108

# PGU: 2 is bad, start at 3, remove 12
# PGU: row 48 was read in sweep 47, so all after sweep 47 are oneoff (sweep 48 to 53 might be ok but we need to realign)
# TRH: remove 27 and 54
# first is "cat sat rat hat", second is 'fat cat sat matt'
# for PGU 59 is u/d of TT, 108 is u/d of JW, 3 is u/d of MA, sents are 3-27, 28-47
# for BNY 59 is u/d of TT, 108 is u/d of JW, 3 is u/d of MA, sents are 3-28, 29-60
# for KVM 59 is u/d of TT,  45 is u/d of JW, 3 is u/d of MA, sents are 2-26, 27-56
# for TRH 17 is u/d of TT, 101 is u/d of JW, 3 is u/d of MA, sents are 2-26, 27-57
# for LLB 59 is u/d of TT,  73 is u/d of JW, 3 is u/d of MA, sents are 2-26, 27-56
# for YSD 59 is u/d of TT, 108 is u/d of JW, no MA, sents are 2-32 (first only)

# for THE 101 is u/d of TT, 59 is u/d of JW, 38,52 is u/d of L, sents are 0, 5-33 (second only)
# for AB0 87 is u/d of TT, 80 is u/d of JW, 66,73 is u/d of L, sents are 0, 9-37 (second only)

# set to calc kinetic extrema within words
calcwextremes = 0

# kinematic parameter to calculate ("DIS", "VEL" or "ACC")
kinematicparameter$ = "DIS"

# set to 1 to draw a Praat Picture
drawpicture = 1

# set to 1 to play the target sounds (only if 'drawpicture' also is set)
playsound = 0

# set to 1 to draw the MARRYS track, if there is one
drawmar = 1

# set to 1 to print the Diff % from audiolog at the top
drawdiff = 1

# set to 1 to save the picture
savepicture = 0

# set to 1 to View and Edit
viewandedit = 0

# set to 1 to pause after each file
pauseaftereach = 1

# use TextGrids
usetextgrids = 1

# set the sweep file you want to start at (5 for THE, 9 for AB0)
### set at top now firstfile = 3
# set lastfile to 0 for all
### set at top now lastfile = 28
##

# set up folder names and which files to loop through
wavfolder$ = myDirectory$+"/wav"
tgfolder$ = myDirectory$+"/out"
marfolder$ = myDirectory$+"/mar2"
emafolder$ = myDirectory$+"/pos"
pngfolder$ = myDirectory$+"/png"
createFolder: pngfolder$
wavstrings = Create Strings as file list: "list", wavfolder$ + "/*.wav"

# remove backups
ns = Get number of strings
i = 1
while i <= ns
	s$ = Get string: i
	l = length(s$)
	if l != 8
		Remove string: i
		ns = ns - 1
	else
		i = i +1
	endif
endwhile

numberOfFiles = Get number of strings
if lastfile == 0
	lastfile = numberOfFiles
endif

# get the strings from the prompter
mslfilestring = Create Strings as file list: "list2", myDirectory$ + "/msl_*"
mslfilestring$ = Get string: 1
mslstrings = Read Strings from raw text file: myDirectory$ + "/" + mslfilestring$

# read the audiolog
ta1 = Read Table from tab-separated file: myDirectory$ + "/" + "audiolog.txt"

# create a table for keeping results
resultsTable = Create Table with column names: "MinMax", 0, { "Speaker", "SentType", "Sweep", "Question", "Diff", "Diffn", "Word", "FocusType", "PosInSent", "Min", "Max", "Clench", "NormMin" }

# first determine mean of clenched
Read from file: emafolder$ + "/" + "0001.txt"
Down to Matrix
Transpose
To Sound (slice): column
Scale times to: 0, 1
Override sampling frequency: 250
clenched = Get mean: 0, 3, 7
sd_clenched = Get standard deviation: 0, 3, 7
#pauseScript: "The mean is: ",clenched," and sd is: ",sd_clenched


# main loop
for ifile from firstfile to lastfile
	selectObject: wavstrings
	wavFileName$ = Get string: ifile
	sweepName$ = left$(wavFileName$,4)
	sweepnumber = number(sweepName$)
	tgFileName$ = replace$(wavFileName$, "wav", "TextGrid",0)
	emaFileName$ = replace$(wavFileName$, "wav", "txt",0)
	aliFileName$ = replace$(wavFileName$, ".wav", "_aligned.wav",0)
	#pauseScript: aliFileName$
	pngFileName$ = replace$(wavFileName$, "wav", "png",0)
	blacklisted = 0
    for i from 1 to size (blacklist#)
		if sweepnumber == blacklist#[i]
			blacklisted = 1
		endif
	endfor
	if not blacklisted
	if fileReadable(tgfolder$ + "/" + tgFileName$) or usetextgrids == 0
		s1 = Read from file: wavfolder$ + "/" + wavFileName$
		Scale intensity: 70

		sw = 1
		ew = 9

        if usetextgrids == 1
		
		tg1 = Read from file: tgfolder$ + "/" + tgFileName$

		# determine which interval to draw
		# default = 4 and 8
		sw = 1
		ew = 9
		select 'tg1'
		ni = Get number of intervals: 1

		# normally, take the first and last nonempty label
		# but in the question sweeps, take the interval with 'yes' or 'no'
		firstnonempty = 0
		yesnoiv = 0
		for iv from 1 to ni
			liv$ = Get label of interval: 1, iv
			if liv$ == "yes" || liv$ == "no"
				yesnoiv = iv
			endif
			if liv$ != ""
				if firstnonempty == 0
					firstnonempty = iv
				endif
				ew = Get end time of interval: 1, iv
			endif
		endfor
		if firstnonempty > 0
			sw = Get start time of interval: 1, firstnonempty
		endif
		if yesnoiv > 0
			sw = Get start time of interval: 1, yesnoiv
		endif

		endif

		if fileReadable(emafolder$ + "/" + emaFileName$)
			s3 = Read from file: emafolder$ + "/" + emaFileName$
			m1 = Down to Matrix
			m2 = Transpose
			s4 = To Sound (slice): column
			Scale times to: 0, 1
			Override sampling frequency: 250
			#Scale peak: 0.99
			bname$ = left$(emaFileName$,4)
			Rename... 'bname$'"_col_"'column'

			name$ = selected$("Sound")
			dis = Copy: "'name$'_DIS"
			vel = To Sound (derivative): 20, 5, 0
			Rename: "'name$'_VEL"
			acc = To Sound (derivative): 20, 5, 0
			#Scale peak: 1
			Rename: "'name$'_ACC"

			if kinematicparameter$ == "DIS"
				select 'dis'
			elsif kinematicparameter$ == "VEL"
				select 'vel'
			elsif kinematicparameter$ == "ACC"
				select 'acc'
			endif

			if viewandedit > 0
				sres = Resample: 48000, 50
				plusObject: s1
				Combine to stereo
				if usetextgrids > 0
					plusObject: tg1
				endif
				View & Edit
				if usetextgrids > 0
					editor: "TextGrid "+bname$
				else
					editor: "Sound combined_2"
				endif
					Sound scaling: "by window and channel", 2, -1, 1
					Mute channels: { 2 }
					Select: sw, ew
					Zoom to selection
					mid = (sw+ew)/2
					Move cursor to... mid
				endeditor
			endif
		endif

		if calcwextremes > 0
			# these are set at top now
			#wordLabels$# = { "cat", "sat", "rat", "hat" }
			#wordLabels$# = { "fat", "cat", "sat", "matt" }
			select 'tg1'
			ni = Get number of intervals: 1

			# normally, take the first and last nonempty label
			# but in the question sweeps, take the interval with 'yes' or 'no'
			firstnonempty = 0
			yesnoiv = 0
			for iv from 1 to ni
				liv$ = Get label of interval: 1, iv
				if liv$ == "yes" || liv$ == "no"
					yesnoiv = iv
				endif
				if yesnoiv > 0
					# cat sat rat hat
					# fat cat sat matt
					if liv$ == wordLabels$# [1]
						siv1 = Get start time of interval: 1, iv
						liv1 = Get end time of interval: 1, iv
					endif
					if liv$ == wordLabels$# [2]
						siv2 = Get start time of interval: 1, iv
						liv2 = Get end time of interval: 1, iv
					endif
					if liv$ == wordLabels$# [3]
						siv3 = Get start time of interval: 1, iv
						liv3 = Get end time of interval: 1, iv
					endif
					# KVM has 'mat'
					if liv$ == wordLabels$# [4]
						siv4 = Get start time of interval: 1, iv
						liv4 = Get end time of interval: 1, iv
					endif
				endif
			endfor

			if yesnoiv > 0

				if drawpicture > 0
					if playsound > 0
						for w from 1 to 4
							select 's1'
							Extract part: siv'w', liv'w', "rectangular", 1, "no"
							Play
							Remove
						endfor
					endif
				endif

				if kinematicparameter$ == "DIS"
					select 'dis'
				elsif kinematicparameter$ == "VEL"
					select 'vel'
				elsif kinematicparameter$ == "ACC"
					select 'acc'
				endif

				for w from 1 to 4
					wmin'w' = Get minimum: siv'w', liv'w', "sinc70"
					wmax'w' = Get maximum: siv'w', liv'w', "sinc70"
				endfor
				selectObject: mslstrings
				mslstring$ = Get string: ifile

				select 'ta1'
				diffp$ = Get value: ifile, "Diff %"
				select 'resultsTable'
				for w from 1 to 4
					nq = elicits#[number(mid$(mslstring$,4,2))]
					nq$ = "NonNarrow"
					if nq== 0
						nq$ = "Broad"
					endif
					if nq == w
						nq$ = "Narrow"
					endif
					Append row
					nr = Get number of rows
					Set string value: nr, "Speaker", speaker$
					Set numeric value: nr, "SentType", wordset
					Set string value: nr, "Sweep", sweepName$
					Set string value: nr, "Question", mid$(mslstring$,3,2)
					Set string value: nr, "Diff", diffp$
					Set numeric value: nr, "Diffn", number(diffp$)
					Set string value: nr, "Word", string$(w) + ". " + wordLabels$#[w]
					#Set string value: nr, "NormQ", elicits$#[number(mid$(mslstring$,4,2))]
					Set string value: nr, "FocusType", nq$
					Set numeric value: nr, "PosInSent", w
					Set numeric value: nr, "Min", wmin'w'
					Set numeric value: nr, "Max", wmax'w'
					Set numeric value: nr, "Clench", clenched
					Set numeric value: nr, "NormMin", wmin'w'-clenched
				endfor
			endif
		endif

		if drawpicture > 0
			Erase all
			Select outer viewport: 0, 12, 0.2, 2.2
			Black
			Solid line
			selectObject: mslstrings
			mslstring$ = Get string: ifile
			if drawdiff == 0
				diffstr$ = ""
			else
				select 'ta1'
				diffp$ = Get value: ifile, "Diff %"
				diffp = number(diffp$)
				diffstr$ = " Diff \% : "+diffp$
				if diffp > 0.001
					diffstr$ = "##"+diffstr$+"#"
				endif
			endif
			topstring$ = "Speaker: "+speaker$+" Sweep: "+bname$+" Column: "+"'column'"+diffstr$+newline$+mslstring$
			Text top: "no", topstring$

			# determine which interval to draw
			# default = 4 and 8
			sw = 4
			ew = 8
			select 'tg1'
			ni = Get number of intervals: 1

			# normally, take the first and last nonempty label
			# but in the question sweeps, take the interval with 'yes' or 'no'
			firstnonempty = 0
			yesnoiv = 0
			for iv from 1 to ni
				liv$ = Get label of interval: 1, iv
				if liv$ == "yes" || liv$ == "no"
					yesnoiv = iv
				endif
				if liv$ != ""
					if firstnonempty == 0
						firstnonempty = iv
					endif
					ew = Get end time of interval: 1, iv
				endif
			endfor
			if firstnonempty > 0
				sw = Get start time of interval: 1, firstnonempty
			endif
			if yesnoiv > 0
				sw = Get start time of interval: 1, yesnoiv
			endif
			
			# draw the EMA track
			if kinematicparameter$ == "DIS"
				select 'dis'
			elsif kinematicparameter$ == "VEL"
				select 'vel'
			elsif kinematicparameter$ == "ACC"
				select 'acc'
			endif

			max = Get maximum: sw, ew, "sinc70"
			min = Get minimum: sw, ew, "sinc70"
			Draw: sw, ew, 0, 0, "yes", "curve"

			# draw lines and labels in the EMA track
			Dotted line
			select 'tg1'
			for iv from 1 to ni
				siv = Get start time of interval: 1, iv
				eiv = Get end time of interval: 1, iv
				miv = (siv + eiv) / 2
				liv$ = Get label of interval: 1, iv

				if siv >= sw && siv < ew
					Draw line: siv, max, siv, min
					Text: miv, "centre", min, "top", liv$
				endif

			endfor

			# draw spectrogram
			select 's1'
			s6 = Extract part: sw, ew, "rectangular", 1, "yes"
			spec1 = noprogress To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
			Select outer viewport: 0, 12, 2.0, 5
			Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "yes"

			# draw F0
			select 's6'
			p1 = noprogress To Pitch (filtered ac): 0, 50, 800, 15, "no", 0.03, 0.09, 0.5, 0.055, 0.35, 0.14
			Blue
			Solid line
			Line width... 2
			Draw: 0, 0, 0, 500, "no"

			# draw sound and textgrid
			Select outer viewport: 0, 12, 5, 8
			select 's1'
			plus 'tg1'
			Black
			Dotted line
			Line width... 1
			Draw: sw, ew, "yes", "yes", "yes"
			#Select outer viewport: 0, 12, 0, 8
			#if savepicture > 0
			#	Save as 300-dpi PNG file: pngfolder$ + "/" + pngFileName$
			#endif
		endif

		havemar = 0
		if fileReadable(marfolder$ + "/" + aliFileName$)
			havemar = 1
			s2 = Read from file: marfolder$ + "/" + aliFileName$
			if viewandedit > 0
				plusObject: tg1
				View & Edit
			endif
		endif

		if havemar > 0 && drawpicture > 0 && drawmar > 0
			Select outer viewport: 0, 12, 0.2, 2.2
			select 's2'
			smar = Extract one channel: 2
			Red
			Draw: sw, ew, 0, 0, "no", "curve"
			select 's2'
			sali = Extract one channel: 3
			Green
			Draw: sw, ew, 0, 0, "no", "curve"
			plus 'smar'
			Remove
			if savepicture > 0
				#Select outer viewport: 0, 12, 0, 8
				# special: just the ema-marrys tracks
				Select outer viewport: 0, 12, 0, 2.5
				Save as 300-dpi PNG file: pngfolder$ + "/" + pngFileName$
			endif
		endif

		if pauseaftereach > 0
	        pauseScript: wavFileName$, " (", ifile, " of ", lastfile, ")"
		endif
		nocheck select all
		minusObject: wavstrings
		minusObject: mslstrings
		minusObject: resultsTable
		minus 'ta1'
		nocheck Remove
		#plusObject: s1
		#Remove
	else
		if pauseaftereach > 0
			pauseScript: "no file", tgFileName$, ", skipping"
		endif
	endif
	else
		if pauseaftereach > 0
			pauseScript: "blacklisted ", sweepName$
		endif		
	endif
endfor

if calcwextremes > 0

select 'resultsTable'

# normalize value relative to clench and absmin
#absmin = Get minimum: "Min"
#clench = Get maximum: "Clench"

#relmin = absmin-clench

#nr = Get number of rows

#for cr from 1 to nr
#	val = Get value: cr, "Min"
#	relval = (val-clench) / -relmin
#	Set numeric value: cr, "NormMin", relval
#endfor

select 'resultsTable'
Save as text file: "/home/johanf/data/donnaalign/MinMax_"+speaker$+"_"+string$(wordset)+".Table"

resultsTable = selected("Table")

#resultsTable = Extract rows where column (number): "Diffn", "less than", 0.001

#minrange = Get minimum: "Min"
#maxrange = Get maximum: "Min"
#maxrange = Get maximum: "Clench"

minrange = Get minimum: "NormMin"
#maxrange = Get maximum: "Min"
maxrange = Get maximum: "NormMin"

minrange = -1
maxrange = 0

# draw all
if 0
Erase all
Select outer viewport: 0, 8, 0, 8
Solid line
Line width... 2



# first: order is 5,2,3,4
# second: order is 2,3,4,5

select 'resultsTable'
tdum3 = Extract rows where column (text): "Question", "is equal to", queryLabels$# [1]
Colour: {1.000000,0.765000,0}
#Box plots: { "Min", "Max" }, "Word", minrange, maxrange, "yes"
Box plots: { "Min" }, "Word", minrange, maxrange, "yes"

select 'resultsTable'
tdum3 = Extract rows where column (text): "Question", "is equal to", queryLabels$# [2]
Colour: {0,0.137000,0.400000}
#Box plots: { "Min", "Max" }, "Word", minrange, maxrange, "yes"
Box plots: { "Min" }, "Word", minrange, maxrange, "yes"

select 'resultsTable'
tdum3 = Extract rows where column (text): "Question", "is equal to", queryLabels$# [3]
Colour: {0,0.502000,0.502000}
#Box plots: { "Min", "Max" }, "Word", minrange, maxrange, "yes"
Box plots: { "Min" }, "Word", minrange, maxrange, "yes"

select 'resultsTable'
tdum3 = Extract rows where column (text): "Question", "is equal to", queryLabels$# [4]
Colour: {0.863000,0.078000,0.235000}
#Box plots: { "Min", "Max" }, "Word", minrange, maxrange, "yes"
Box plots: { "Min" }, "Word", minrange, maxrange, "yes"

select 'resultsTable'
tdum1 = Extract rows where column (text): "Question", "is equal to", queryLabels$# [5]
Colour: "black"
Line width... 2
#Box plots: { "Min", "Max" }, "Word", minrange, maxrange, "no"
Box plots: { "Min" }, "Word", minrange, maxrange, "yes"

#wordset = 0
Select outer viewport: 0, 8, 7.5, 9
if wordset == 1
	Viewport text: "centre", "half", 0, "Narrow - cat (yellow) sat (blue) rat (green) hat (red)" + newline$ + "Broad - black"
endif
if wordset == 2
	Viewport text: "centre", "half", 0, "Narrow - fat (yellow) cat (blue) sat (green) matt (red)" + newline$ + "Broad - black"
endif

endif

# draw individual
if 0
if wordset == 1
@drawOneBoxPlot: "Q5", "{1.000000,0.765000,0}", "1. cat (yellow)", 1, 1
@drawOneBoxPlot: "Q2", "{0,0.137000,0.400000}", "2. sat (blue)", 1, 1
@drawOneBoxPlot: "Q3", "{0,0.502000,0.502000}", "3. rat (green)", 1, 1
@drawOneBoxPlot: "Q4", "{0.863000,0.078000,0.235000}", "4. hat (red)", 1, 1
@drawOneBoxPlot: "Q1", "black", "5. Broad - black", 1, 1
endif
if wordset == 2
@drawOneBoxPlot: "Q2", "{1.000000,0.765000,0}", "1. fat (yellow)", 1, 1
@drawOneBoxPlot: "Q3", "{0,0.137000,0.400000}", "2. cat (blue)", 1, 1
@drawOneBoxPlot: "Q4", "{0,0.502000,0.502000}", "3. sat (green)", 1, 1
@drawOneBoxPlot: "Q5", "{0.863000,0.078000,0.235000}", "4. matt (red)", 1, 1
@drawOneBoxPlot: "Q1", "black", "5. Broad - black", 1, 1
endif

procedure drawOneBoxPlot: .tQ$, .col$, .legend$, .erase, .save
# .tQ = targetQuestion
# .col = color
# .legend = legend below the drawing
# .erase = erase before drawing
# .save = save drawing or not
if .erase
	Erase all
endif

Select outer viewport: 0, 8, 0, 8
Solid line
Line width... 5

# this has to be selected before calling the procedure
resultsTable = selected("Table")

#resultsTable = Extract rows where column (number): "Diffn", "less than", 0.001

minrange = Get minimum: "Min"
maxrange = Get maximum: "Min"

select 'resultsTable'
targetRows = Extract rows where column (text): "Question", "is equal to", .tQ$
Colour: .col$
#Box plots: { "Min", "Max" }, "Word", minrange, maxrange, "yes"
Box plots: { "Min" }, "Word", minrange, maxrange, .erase
Remove

if length(.legend$)
	Colour: "black"
	Select outer viewport: 0, 8, 7.5, 9
	Viewport text: "centre", "half", 0, speaker$ + " - " + string$(wordset) + " - " + .legend$
endif

if .save
	# save it :)
	Select outer viewport: 0, 8, 0, 9
	Save as 300-dpi PNG file: "/home/johanf/data/donnaalign/per_spea_and_cond/"+speaker$+"-"+string$(wordset)+"-"+left$(.legend$,1)+"-"+mid$(.legend$,4,3)+"-300.png"
endif

# end by re-selecting the table that was selected
select 'resultsTable'

#pauseScript: "pause"

endproc

endif

###################################
###################################

if 1

resultsTable = selected("Table")

minrange = Get minimum: "NormMin"
maxrange = Get maximum: "NormMin"
#minrange = -1
#maxrange = 0

# draw all
#if 1
Erase all
Select outer viewport: 0, 8, 0, 8
Solid line
Line width... 2

select 'resultsTable'
tdum3 = Extract rows where column (text): "FocusType", "is equal to", "Narrow"
Colour: {0,0.502000,0.502000}
#Box plots: { "Min", "Max" }, "NormW", minrange, maxrange, "yes"
Box plots: { "NormMin" }, "PosInSent", minrange, maxrange, "yes"

#select 'resultsTable'
#tdum3 = Extract rows where column (text): "NormQ", "is equal to", "NonNarrow"
#tdum3 = Extract rows where column (text): "NormQ", "is not equal to", "Narrow"
#Colour: {0.863000,0.078000,0.235000}
#Box plots: { "Min", "Max" }, "NormW", minrange, maxrange, "yes"
#Box plots: { "NormMin" }, "NormW", minrange, maxrange, "yes"

select 'resultsTable'
tdum3 = Extract rows where column (text): "FocusType", "is equal to", "Broad"
Colour: "black"
#Box plots: { "Min", "Max" }, "NormW", minrange, maxrange, "yes"
Box plots: { "NormMin" }, "PosInSent", minrange, maxrange, "yes"

endif

endif

