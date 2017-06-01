#!/bin/bash

usage() { echo "Usage: $0 -e <model name> -s <model language>" 1>&2; exit 1; }

DATA_URL=http://techiaith.cymru/kaldi/language_corpus

source ./path.sh

while getopts "e:" o; do
	case "${o}" in
		e)
			NAME=${OPTARG}		
			echo "Name of model/engine/collection : ${NAME}" 
			;;
		*)
			usage	
			;;
	esac
done  
shift $((OPTIND-1))

if [ -z "${NAME}" ]; then
    usage
fi

wget -P ${TEST_ROOT} -N -nd -c -e robots=off -r -np ${DATA_URL}/${NAME}.tar.gz || \
 { echo "WGET error"'!' ; exit 1 ; }

tar -zxf ${TEST_ROOT}/${NAME}.tar.gz --directory ${TEST_ROOT}

python ./local/make_corpus_txt.py 

source ./local/downsample_test.sh

