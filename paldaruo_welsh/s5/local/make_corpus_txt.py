#!/usr/bin/env python
import os, path, utils, csv, codecs
import sanitize

def make_corpus_text_file(source_dir, prompts_file, destination):

	prompts = utils.get_prompts(os.path.join(source_dir,prompts_file))
	text_file = codecs.open(os.path.join(destination,'corpus.tmp'),'w', encoding='utf-8')

	for key,value in prompts.items():
		text_file.write(value + '\n')
		
	text_file.close()

testdata_dir = path.get_var('path.sh','TEST_ROOT')
datalocal_dir = path.get_var('path.sh','KALDI_DATA_LOCAL_ROOT')

make_corpus_text_file(testdata_dir, 'samples.txt', datalocal_dir)
sanitize.sanitize_file(os.path.join(datalocal_dir,'corpus.tmp'),os.path.join(datalocal_dir,'corpus.txt'))

os.remove(os.path.join(datalocal_dir,'corpus.tmp'))

