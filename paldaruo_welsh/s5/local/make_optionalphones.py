#!/usr/bin/env python
import os,sets, path
from argparse import ArgumentParser

dest_dir = path.get_var('path.sh','KALDI_LEXICON_ROOT')

optional_phoneset = set()
optional_phoneset.add('<s>','</s>')

with open(os.path.join(dest_dir,'optional_silence.txt'),'w') as optsilence:
    for phone in optional_phoneset:
	optsilence.write(phone + '\n')

