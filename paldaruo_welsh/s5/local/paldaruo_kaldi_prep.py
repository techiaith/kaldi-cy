#!/usr/bin/env python
import os, sys, csv, utils, getopt, codecs

def make_spk2gender_file(source_dir, meta_file, destination_dir):

	print 'make_spk2gender(' + source_dir + ', ' + destination_dir + ')'

	spk2gender_file = open(destination_dir + '/spk2gender.map','w')
	metadata_file = csv.DictReader(open(os.path.join(source_dir, meta_file)))

	for row in metadata_file:
		speaker = row['uid']
		gender = row['rhyw']

		if gender == 'benyw' or gender == 'female': 
			kaldi_gender = 'f'
		else: 
			kaldi_gender = 'm'

		spk2gender_file.write(speaker + ' ' + kaldi_gender + '\n')

	spk2gender_file.close()


def make_utt2spk_file(source_dir, meta_file, destination_dir):

	print 'make_utt2spk(' + source_dir + ', ' + destination_dir + ')'

        audio_data_files = utils.get_directory_structure(source_dir)
        metadata_file = csv.DictReader(open(os.path.join(source_dir,meta_file)))
        utt2spk_file = open(os.path.join(destination_dir,'utt2spk'),'w')

	utt2spk_file_content = []

        for row in metadata_file:
                speaker = row['uid']
		speakerdir = os.path.join(source_dir, speaker)
                if os.path.isdir(speakerdir):
                        for wav in audio_data_files[speaker]:
				if not os.path.isfile(os.path.join(source_dir,speaker,wav)): continue
                                if wav.startswith("silence"): continue
                                fileid = speaker + "_" + wav.split('.')[0]
				utt2spk_file_content.append(fileid + " " + speaker)

	utt2spk_file_content.sort()
	for line in utt2spk_file_content:
		utt2spk_file.write("%s\n" % line)
	
        utt2spk_file.close()


def make_wavscp_file(source_dir, meta_file, destination_dir):

	print 'make_wavscp(' + source_dir + ', ' + destination_dir + ')'

        audio_data_files = utils.get_directory_structure(source_dir)
        wavscp_file = open(os.path.join(destination_dir,'wav.scp'),'w')
        metadata_file = csv.DictReader(open(os.path.join(source_dir, meta_file)))

	wavscp_file_content = []

        for row in metadata_file:
                speaker = row['uid']
                if os.path.isdir(os.path.join(source_dir, speaker)):
                        for wav in audio_data_files[speaker]:
				if not os.path.isfile(os.path.join(source_dir,speaker,wav)): continue
                                if (wav.startswith("silence")): continue
                                fileid = speaker + "_" + wav.split('.')[0]
                                absolutepath = source_dir + "/" + speaker + "/" + wav
				wavscp_file_content.append(fileid + " " + absolutepath)

	wavscp_file_content.sort()
	for line in wavscp_file_content:
		wavscp_file.write("%s\n" % line)

        wavscp_file.close()


def make_text_file(source_dir, meta_file, prompts_file, destination_dir):

	print 'make_text_file(' + source_dir + ', ' + destination_dir + ')'
      
 	audio_data_files = utils.get_directory_structure(source_dir)
        prompts = utils.get_prompts(os.path.join(source_dir,prompts_file))

        text_file = codecs.open(os.path.join(destination_dir,'text'),'w', encoding='utf-8')
        metadata_file = csv.DictReader(open(os.path.join(source_dir, meta_file)))

 	textfile_content = []

        for row in metadata_file:
                speaker = row['uid']
                if os.path.isdir(os.path.join(source_dir, speaker)):
                        for promptId, text in prompts.iteritems():
                                wavfile=promptId + '.wav'
                                if wavfile in audio_data_files[speaker]:
                                        fileid = speaker + "_" + promptId
					textfile_content.append(fileid + ' ' + text)
	
	textfile_content.sort()
        for line in textfile_content:
                text_file.write("%s\n" % line)

        text_file.close()

def usage():
	print "paldaruo_kaldi_prep.py -a,--audiodir <audio_dir> -d,--datadir <data_dir> -t,--datatype train|dev|test"

 
def main():
	source_dir = ''
	destination_dir = ''
	data_type = ''
	try:
		opts, args = getopt.getopt(sys.argv[1:], "ha:d:t:",["audiodir=","datadir=","datatype="])
		if len(opts) != 3:
			raise getopt.GetoptError("Missing arguments")
	except getopt.GetoptError, msg:
		print msg
		usage()	
		sys.exit(2)

	for opt, arg in opts:
		if opt == '-h':
			usage()	
			sys.exit()
		elif opt in ("-a", "--audiodir"):
			source_dir = arg
		elif opt in ("-d", "--datadir"):
			destination_dir = arg
        	elif opt in ("-t", "--datatype"):
			data_type = arg        
		else:
			assert False, "unhandled option"

        destination_dir = os.path.join(destination_dir, data_type)
	
	if not os.path.exists(destination_dir):
		os.makedirs(destination_dir)

	make_spk2gender_file(source_dir, "metadata.csv", destination_dir)
	make_utt2spk_file(source_dir,"metadata.csv", destination_dir)
	make_wavscp_file(source_dir,"metadata.csv", destination_dir)
	make_text_file(source_dir, "metadata.csv", "samples.txt", destination_dir)

if __name__ == "__main__":
	main()

