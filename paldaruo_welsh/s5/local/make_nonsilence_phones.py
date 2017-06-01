#!/usr/bin/env python
import os,sets, path
from argparse import ArgumentParser

dest_dir = path.get_var('path.sh','KALDI_LEXICON_ROOT')

phoneset = set()
phoneset_add = phoneset.add

with open(os.path.join(dest_dir,'lexicon.txt'),'rb') as lex:

    for line in lex:
        (key, val) = line.split(' ',1)
        val = val.lstrip().rstrip()
        phonemes = val.split(' ')

        [x for x in phonemes if not (x in phoneset or phoneset_add(x))]

sorted_phones = sorted(phoneset, key=lambda s: s.lower())

with open(os.path.join(dest_dir,'nonsilence_phones.txt'),'w') as nonsilence:
    for phone in sorted_phones:
	if phone=='SPN': continue
        nonsilence.write(phone + '\n')

str_phones = ', '.join(sorted_phones)
print str_phones

