#!/usr/bin/env python

import sys, os, errno, re, codecs, utils
from argparse import ArgumentParser

lexicon = {}
token_exceptions = ["'","R"]

lexicon_dir = 'data/local/dict'

with open(lexicon_dir + '/lexicon.txt') as lexicon_file:
	for line in lexicon_file:
		elements = line.rstrip().split(' ',1)
		key = elements[0].replace('*/','')
		lexicon[key]=elements[1]


def sanitize_file(infile, outfile, **args):

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
				print tokens_out_string
				out_file.write(tokens_out_string + "\n")
			else:
				print "Skipped " + upper.encode('utf-8') + ", " + tokens_out_string.encode('utf-8') + ", " + last_token.encode('utf-8')
	
	out_file.close()

if __name__ == "__main__":
	
	parser = ArgumentParser(description="Trosi ffeil i gyd i upper, ei docyneiddio a'i baratoi ar gyfer hyfforddi model iaith")

	parser.add_argument('-i', '--in', dest="infile", required=True, help="y ffeil ar gyfer priflythrennu")
	parser.add_argument('-o', '--out', dest="outfile", required=True, help="i ble dylid cadw'r ffeil wedi'i priflythrennu")
	parser.set_defaults(func=sanitize_file)

	args=parser.parse_args()
	args.func(**vars(args))

