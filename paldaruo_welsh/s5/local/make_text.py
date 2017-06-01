#!/usr/bin/env python
import os, path, utils, csv, codecs

data_dir = path.get_var('path.sh','DATA_ROOT')
testdata_dir = path.get_var('path.sh','TEST_ROOT')
kaldidata_dir = path.get_var('path.sh','KALDI_DATA_ROOT')

train_dir =  os.path.join(kaldidata_dir,'train')
test_dir = os.path.join(kaldidata_dir, 'test')

def make_text_file(source_dir, meta_file, prompts_file, destination):

	audio_data_files = utils.get_directory_structure(source_dir)
	prompts = utils.get_prompts(os.path.join(source_dir,prompts_file))
	
	text_file = codecs.open(destination + '/text','w', encoding='utf-8')
	metadata_file = csv.DictReader(open(os.path.join(source_dir,meta_file)))

	for row in metadata_file:
		speaker = row['uid']
		if (os.path.isdir(source_dir + "/" + speaker)):
			for promptId,text in prompts.iteritems():
				wavfile=promptId + '.wav'
				if wavfile in audio_data_files[speaker]:
					fileid = speaker + "_" + promptId
					print fileid , repr(text) #text.encode('utf-8')
					text_file.write(fileid + ' ' + text + '\n')			

	text_file.close()

make_text_file(data_dir, 'metadata.csv', 'samples.txt', train_dir)
make_text_file(testdata_dir, 'metadata.csv', 'samples.txt', test_dir)

