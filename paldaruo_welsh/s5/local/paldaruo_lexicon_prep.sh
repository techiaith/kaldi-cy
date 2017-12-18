#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

DATA_SRC="http://techiaith.cymru/lts/"

lexicon_dir=$1

mkdir -p $lexicon_dir

# Check if the executables needed for this script are present in the system
command -v wget >/dev/null 2>&1 ||\
 { echo "\"wget\" is needed but not found"'!'; exit 1; }

echo "--- Starting lexicon data download from ${DATA_SRC} ---"
wget -P ${lexicon_dir} -q -N -nd -c -e robots=off -A txt,lexicon -r -np ${DATA_SRC} || \
 { echo "WGET error"'!' ; exit 1 ; }
echo "--- Download complete ---"

cat ${lexicon_dir}/cym.lexicon | uniq > ${lexicon_dir}/lexicon.txt
echo "<UNK> SPN" >> ${lexicon_dir}/lexicon.txt 
rm ${lexicon_dir}/cym.lexicon

