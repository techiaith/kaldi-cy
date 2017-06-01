#!/usr/bin/env python
import os,sets, path
from argparse import ArgumentParser

dest_dir = path.get_var('path.sh','KALDI_LEXICON_ROOT')

questions = set()

with open(os.path.join(dest_dir,'extra_questions.txt'),'w') as extraquestions:
    for question in questions:
        extraquestions.write(question + '\n')

