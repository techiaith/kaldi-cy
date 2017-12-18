#!/usr/bin/env python
import os, sys, getopt, utils, csv, codecs, errno, re
from subprocess import call

lexicon = {}
token_exceptions = ["'","R"]

#lexicon_dir = 'data/local/dict'

def initialise_lexicon(lexicon_dir):
	with open(lexicon_dir + '/lexicon.txt') as lexicon_file:
        	for line in lexicon_file:
                	elements = line.rstrip().split(' ',1)
                	key = elements[0].replace('*/','')
                	lexicon[key]=elements[1]


def sanitize_file(infile, outfile):

        out_file = codecs.open(outfile,'wb+', encoding='utf-8')

        with codecs.open(infile,'r', encoding='utf-8') as in_file:
                for line in in_file.readlines():
                        upper=line.rstrip('\n').upper()
                        tokens = tuple(re.findall(r"(?:^|\b).(?:\B.)*",upper))
                        tokens_out=[]
                        write_to_file=False
                        last_token=''

                        for token in tokens:
                                last_token=token
                                if token.isalpha() or token in token_exceptions:
                                        if token in lexicon or token in token_exceptions:
                                                tokens_out.append(token)
                                                write_to_file=True

                                if write_to_file:
                                        continue

                                write_to_file=False
                                break


                        tokens_out_string = ' '.join(tokens_out)
                        tokens_out_string = tokens_out_string.replace(" ' ","'")
                        tokens_out_string = '<s> %s </s>' % tokens_out_string

                        if write_to_file:
                                #print tokens_out_string
                                out_file.write(tokens_out_string + "\n")
                        else:
                                print "Skipped " + upper.encode('utf-8') + ", " + tokens_out_string.encode('utf-8') + ", " + last_token.encode('utf-8')

        out_file.close()


def make_corpus_text_file(source_dir, prompts_file, destination):
	
	out_file=os.path.join(destination,'corpus.tmp')
        prompts = utils.get_prompts(os.path.join(source_dir,prompts_file))
        text_file = codecs.open(out_file,'w', encoding='utf-8')

        for key,value in prompts.items():
                text_file.write(value + '\n')

        text_file.close()
	return out_file


def usage():
        print "paldaruo_lm_prep.py -t,--testdir <test data directory> -l,--localdir <local directory e.g. /data/local> -o,--lmorder <language model order e.g. 3> -x,--lexicondir <lexicon directory>" 

def main():

        # arguments
        datatest_dir = ''
	datalocal_dir = ''
	lexicon_dir = ''
	lm_order = 0;
        try:
                opts, args = getopt.getopt(sys.argv[1:], "ha:t:l:o:x:",["--testdir=","--localdir=","--lmorder","--lexicondir"])
                if len(opts) != 4:
                        raise getopt.GetoptError("Missing arguments")
        except getopt.GetoptError, msg:
                print msg
                usage()
                sys.exit(2)

        for opt, arg in opts:
                if opt == '-h':
                        usage()
                        sys.exit()
                elif opt in ("-t", "--testdir"):
                        datatest_dir = arg
                elif opt in ("-l", "--localdir"):
                        datalocal_dir = arg
		elif opt in ("-x", "--lexicondir"):
			lexicon_dir = arg
		elif opt in ("-o", "--lmorder"):
			lm_order = arg                 
                else:
                        assert False, "unhandled option"

	if not os.path.exists(datalocal_dir):
		os.makedirs(datalocal_dir)

	datalocal_tmpdir = os.path.join(datalocal_dir, "tmp")
	if not os.path.exists(datalocal_tmpdir):
		os.makedirs(datalocal_tmpdir)

	initialise_lexicon(lexicon_dir)
	corpus_text_file = os.path.join(datalocal_dir,"corpus.txt")
        tmp_corpus_file = make_corpus_text_file(datatest_dir, "samples.txt", datalocal_dir)
	sanitize_file(tmp_corpus_file, os.path.join(datalocal_dir,"corpus.txt"))
	os.remove(tmp_corpus_file)	


	print "Creating ngram-count using SRILM ...."
	call(["ngram-count","-version"])

	print "text file; 	" + os.path.join(datalocal_dir, "corpus.txt")
	print "vocab file: 	" + os.path.join(datalocal_tmpdir,"vocab-full.txt")
	print "lm file: 	" + os.path.join(datalocal_tmpdir, "lm.arpa")

	ngram_count_call = ["ngram-count",
		"-order", lm_order, 
		"-write-vocab", os.path.join(datalocal_tmpdir,"vocab-full.txt"),
		"-wbdiscount",
		"-text", os.path.join(datalocal_dir, "corpus.txt"),
		"-lm", os.path.join(datalocal_tmpdir,"lm.arpa")]
	gz_call = ["gzip", os.path.join(datalocal_tmpdir,"lm.arpa")]

	#print ngram_count_call
	#print gz_call
	call(ngram_count_call)
	call(gz_call)

	print "Completed creating ngram-count"

if __name__ == "__main__":
        main()

