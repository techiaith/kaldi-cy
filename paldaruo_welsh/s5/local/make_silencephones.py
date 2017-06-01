#!/usr/bin/env python
import os,sets, path
from argparse import ArgumentParser

dest_dir = path.get_var('path.sh','KALDI_LEXICON_ROOT')

phoneset = set()
phoneset.add('sil')
phoneset.add('SPN')

with open(os.path.join(dest_dir,'silence_phones.txt'),'w') as silence:
    for phone in phoneset:
        silence.write(phone + '\n')

