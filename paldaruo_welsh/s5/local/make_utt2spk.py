#!/usr/bin/env python
import os, path, utils, csv

data_dir = path.get_var('path.sh','DATA_ROOT')
testdata_dir = path.get_var('path.sh','TEST_ROOT')
kaldidata_dir = path.get_var('path.sh','KALDI_DATA_ROOT')

train_dir =  os.path.join(kaldidata_dir,'train')
test_dir = os.path.join(kaldidata_dir, 'test')

def make_utt2spk_file(source_dir, meta_file, destination):

	audio_data_files = utils.get_directory_structure(source_dir)	
	utt2spk_file = open(destination + '/utt2spk','w')
	metadata_file = csv.DictReader(open(os.path.join(source_dir,meta_file)))

	for row in metadata_file:
		speaker = row['uid']
		if (os.path.isdir(source_dir + "/" + speaker)):
			for wav in audio_data_files[speaker]:
				if (wav.startswith("silence")): continue
				fileid = speaker + "_" + wav.split('.')[0]
				print fileid + " " + speaker	
				utt2spk_file.write(fileid + " " + speaker + "\n")

	utt2spk_file.close()

make_utt2spk_file(data_dir, 'metadata.csv', train_dir)
make_utt2spk_file(testdata_dir, 'metadata.csv', test_dir)

