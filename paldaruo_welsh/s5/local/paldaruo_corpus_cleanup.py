#!/usr/bin/env python
import os
import sys
import errno

corpus_dir=sys.argv[1]
all_info_sorted_location=sys.argv[2]

all_info = {}

# Example content of all_info.sorted.txt
#
#b821b693-175c-434f-a13e-8b7fb801bb52_sample42 3 ^I7^I SIR_BENFRO GWELD GILYDD OND_DOEDD OES LLUN WRTH YN_GWNEUD YSTOD^I SIR_BENFRO GWELD GILYDD OND_DOEDD OES UN_O'CH_FFRINDIAU YSTOD$
#9d9b2598-f0fa-495e-8300-5a6c88bf89ad_sample32 3 ^I7^I AMGYLCHIADAU GWEITHWYR FY_MAM RHAN RHOI I_GYD PETHAU UNRHYW DRWS^I AMGYLCHIADAU GWEITHWYR FY_MAM AC_YN_LLOGI PETHAU UNRHYW DRWS$

with open(all_info_sorted_location) as all_info_sorted_file:
	for line in all_info_sorted_file:
		# we only require the utterance-id and number of errors, seperated by space at begining of line. 
		all_info_top_fields=line.split(' ', 2)
		utterance_id=all_info_top_fields[0]
		nerrors=int(all_info_top_fields[1])
		
		if nerrors > 0: 
			# convert from utterance id to wav file 
			uid, sampleid = utterance_id.split('_')
			try:
				wavfile = os.path.join(corpus_dir, uid, sampleid + '.wav')
				os.remove(wavfile)
				print ("Removed %s" % wavfile)
			except OSError as e:
				if e.errno != errno.ENOENT:
					raise
