#!/usr/bin/env python
import os, csv, path

data_dir = path.get_var('path.sh','DATA_ROOT')
testdata_dir = path.get_var('path.sh','TEST_ROOT')
kaldidata_dir = path.get_var('path.sh','KALDI_DATA_ROOT')

train_dir =  os.path.join(kaldidata_dir,'train')
test_dir = os.path.join(kaldidata_dir, 'test')

def make_spk2gender_file(source, destination):

	print 'make_spk2gender(' + source + ', ' + destination + ')'

	spk2gender_file = open(destination + '/spk2gender.map','w')
	metadata_file = csv.DictReader(open(source))
	for row in metadata_file:
		speaker = row['uid']
		gender_cy = row['rhyw']
		if gender_cy == 'benyw': 
			gender= 'f'
		else: 
			gender= 'm'
		#print speaker + ' ' + gender + ' (' + str(gender_cy) + ')'
		spk2gender_file.write(speaker + ' ' + gender + '\n')

	spk2gender_file.close()

make_spk2gender_file(data_dir + '/metadata.csv', train_dir)
make_spk2gender_file(testdata_dir + '/metadata.csv', test_dir)

