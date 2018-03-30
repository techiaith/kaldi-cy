#!/usr/bin/env python3
import os, sys, getopt, utils, csv, errno, re
from subprocess import call

lexicon = {}
token_exceptions = ["'","R"]

#lexicon_dir = 'data/local/dict'

def initialise_lexicon(lexicon_dir):
	with open(lexicon_dir + '/lexicon.txt', 'r', encoding='utf-8') as lexicon_file:
        	for line in lexicon_file:
                	elements = line.rstrip().split(' ',1)
                	key = elements[0].replace('*/','')
                	lexicon[key]=elements[1]


def sanitize_file(infile, outdir, outfile):

	out_file = open(outfile, 'w', encoding='utf-8')
	oov_filelocation = os.path.join(outdir,"oov.txt")
	oov_file = open(oov_filelocation, 'w', encoding='utf-8')

	oov_set = set()

	with open(infile, 'r', encoding='utf-8') as in_file:

                for line in in_file.readlines():
                        upper=line.rstrip('\n').upper()
                        tokens = tuple(re.findall(r"\S+", upper))
                        tokens_out=[]
                        write_to_file=True
                        last_token=''

                        for token in tokens:
                                last_token=token
                                tokens_out.append(token)
                                if not token in lexicon and not token in token_exceptions:
                                        oov_set.add(token)
                                        write_to_file=False

                        tokens_out_string = ' '.join(tokens_out)
                        tokens_out_string = tokens_out_string.replace(" ' ","'")
                        tokens_out_string = '<s> %s </s>' % tokens_out_string

                        if write_to_file:
                                out_file.write(tokens_out_string + "\n")

	out_file.close()

	oov_count=0	
	for oov in sorted(oov_set):
		oov_file.write(oov + "\n")
		oov_count += 1

	oov_file.close()
	print ("%s OOV words written %s" % (oov_count, oov_filelocation))


def usage():
        print ("paldaruo_lm_prep.py -d,--datadir <directory containing input data> -f, --datafile <file containing input data> -l,--localdir <local/output directory e.g. /data/local> -o,--lmorder <language model order e.g. 3> -x,--lexicondir <lexicon directory>") 


def main():

        # arguments
	data_dir = ''
	data_file = ''

	datalocal_dir = ''
	lexicon_dir = ''
	lm_order = 0;

	try:
                opts, args = getopt.getopt(sys.argv[1:], "ha:d:f:l:o:x:",["--datadir=","--datafile=","--localdir=","--lmorder=","--lexicondir="])
                if len(opts) != 5:
                        raise getopt.GetoptError("Missing arguments")

	except (getopt.GetoptError, msg):
                print (msg)
                usage()
                print (sys.argv[1:])
                sys.exit(2)

	for opt, arg in opts:
                if opt == '-h':
                        usage()
                        sys.exit()
                elif opt in ("-d", "--datadir"):
                        data_dir = arg
                        print ("-d, --datatdir:" + data_dir)
                elif opt in ("-f", "--datafile"):
                        data_file = arg
                        print ("-f,--data_file: " + data_file)
                elif opt in ("-l", "--localdir"):
                        datalocal_dir = arg
                        print ("-l, --localdir: " + datalocal_dir)
                elif opt in ("-x", "--lexicondir"):
                        lexicon_dir = arg
                        print ("-x, --lexicondir: " + lexicon_dir)
                elif opt in ("-o", "--lmorder"):
                        lm_order = arg 
                        print ("-o, --lmorder: " + lm_order)
                else:
                        assert False, "unhandled option"

	if not os.path.exists(datalocal_dir):
		os.makedirs(datalocal_dir)

	datalocal_tmpdir = os.path.join(datalocal_dir, "tmp")
	if not os.path.exists(datalocal_tmpdir):
		os.makedirs(datalocal_tmpdir)

	print ("Sanitizing text data ....")
	initialise_lexicon(lexicon_dir)
	sanitize_file(os.path.join(data_dir, data_file), datalocal_dir, os.path.join(datalocal_dir,"corpus.txt"))

	print ("Creating ngram-count using SRILM ....")
	#call(["ngram-count","-version"])

	print ("text file; 	" + os.path.join(datalocal_dir, "corpus.txt"))
	print ("vocab file: 	" + os.path.join(datalocal_tmpdir,"vocab-full.txt"))
	print ("lm file: 	" + os.path.join(datalocal_tmpdir, "lm.arpa"))

	ngram_count_call = ["ngram-count",
		"-order", lm_order, 
		"-write-vocab", os.path.join(datalocal_tmpdir,"vocab-full.txt"),
		"-wbdiscount",
		"-text", os.path.join(datalocal_dir, "corpus.txt"),
		"-lm", os.path.join(datalocal_tmpdir,"lm.arpa")]

	gz_call = ["gzip", os.path.join(datalocal_tmpdir,"lm.arpa")]

	call(ngram_count_call)
	call(gz_call)

	print ("Completed creating ngram-count")

if __name__ == "__main__":
        main()

