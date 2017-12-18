#!/usr/bin/env python
import os, sys, getopt, sets

phoneset = set()
phoneset_add = phoneset.add

silent_phoneset = set()
silent_phoneset.add('sil')
silent_phoneset.add('SPN')

optional_phoneset = set()
optional_phoneset.add('sil')

questions = set()


def make_nonsilence_phones(lexicon_dir):

	print "make_nonsilence_phones " + lexicon_dir

	with open(os.path.join(lexicon_dir,'lexicon.txt'),'rb') as lex:
		for line in lex:
			(key, val) = line.split(' ',1)
			val = val.lstrip().rstrip()
			phonemes = val.split(' ')

        		[x for x in phonemes if not (x in phoneset or phoneset_add(x))]

	sorted_phones = sorted(phoneset, key=lambda s: s.lower())

	with open(os.path.join(lexicon_dir,'nonsilence_phones.txt'),'w') as nonsilence:
		for phone in sorted_phones:
			if phone=='SPN': continue
			nonsilence.write(phone + '\n')

	str_phones = ', '.join(sorted_phones)
	print str_phones



def make_silence_phones(lexicon_dir):

	print "make_silence_phones " + lexicon_dir

	with open(os.path.join(lexicon_dir,'silence_phones.txt'),'w') as silence:
		for phone in silent_phoneset:
			silence.write(phone + '\n')


def make_optionalphones(lexicon_dir):

	print "make_optionalphones " + lexicon_dir

	with open(os.path.join(lexicon_dir,'optional_silence.txt'),'w') as optsilence:
		for phone in optional_phoneset:
			optsilence.write(phone + '\n')


def make_extraquestions(lexicon_dir):

	print "make_extraquestions " + lexicon_dir

	with open(os.path.join(lexicon_dir,'extra_questions.txt'),'w') as extraquestions:
		for question in questions:
			extraquestions.write(question + '\n')

def usage():
        print "paldaruo_phones_prep.py -d,--lexicondir <lexicon root directory>"


def main():
	lexicon_dir = ''
	try:
		opts, args = getopt.getopt(sys.argv[1:], "hd:",["lexicondir="])
                if len(opts) != 1:
                        raise getopt.GetoptError("Missing arguments")
        except getopt.GetoptError, msg:
                print msg
                usage()
                sys.exit(2)

        for opt, arg in opts:
                if opt == '-h':
                        usage()
                        sys.exit()
                elif opt in ("-d", "--lexicondir"):
                        lexicon_dir = arg
                else:
                        assert False, "unhandled option"

        if not os.path.exists(lexicon_dir):
                os.makedirs(lexicon_dir)

        make_nonsilence_phones(lexicon_dir)
	make_silence_phones(lexicon_dir)
	make_optionalphones(lexicon_dir)
	make_extraquestions(lexicon_dir)


if __name__ == "__main__":
        main()

