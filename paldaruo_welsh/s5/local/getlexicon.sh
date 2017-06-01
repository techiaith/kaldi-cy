#!/bin/bash

DATA_SRC="http://techiaith.cymru/lts/"

source ./path.sh

# Check if the executables needed for this script are present in the system
command -v wget >/dev/null 2>&1 ||\
 { echo "\"wget\" is needed but not found"'!'; exit 1; }

echo "--- Starting data download ..."
wget -P ${KALDI_LEXICON_ROOT} -N -nd -c -e robots=off -A txt,lexicon -r -np ${DATA_SRC} || \
 { echo "WGET error"'!' ; exit 1 ; }

cat ${KALDI_LEXICON_ROOT}/cym.lexicon | uniq > ${KALDI_LEXICON_ROOT}/lexicon.txt
echo "<UNK> SPN" >> ${KALDI_LEXICON_ROOT}/lexicon.txt 
rm ${KALDI_LEXICON_ROOT}/cym.lexicon
