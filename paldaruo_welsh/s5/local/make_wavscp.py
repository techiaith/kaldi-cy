#!/usr/bin/env python
import os, path, utils, csv

data_dir = path.get_var('path.sh','DATA_ROOT')
testdata_dir = path.get_var('path.sh','TEST_ROOT')
kaldidata_dir = path.get_var('path.sh','KALDI_DATA_ROOT')

train_dir =  os.path.join(kaldidata_dir,'train')
test_dir = os.path.join(kaldidata_dir, 'test')

def make_wavscp_file(source_dir, meta_file, destination):

	audio_data_files = utils.get_directory_structure(source_dir)
	wavscp_file = open(destination + '/wav.scp','w')
	metadata_file = csv.DictReader(open(os.path.join(source_dir, meta_file)))
	
	for row in metadata_file:
		speaker = row['uid']	
		if (os.path.isdir(source_dir + "/" + speaker)):
			for wav in audio_data_files[speaker]:
				if (wav.startswith("silence")): continue
				fileid = speaker + "_" + wav.split('.')[0]
				absolutepath = source_dir + "/" + speaker + "/" + wav
				print fileid + " " + absolutepath	
				wavscp_file.write(fileid + " " + absolutepath + "\n")

	wavscp_file.close()

make_wavscp_file(data_dir, 'metadata.csv', train_dir)
make_wavscp_file(testdata_dir, 'metadata.csv', test_dir)

