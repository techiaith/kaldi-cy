#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

audio_data=$1
testset_name=$2

DATA_URL=http://techiaith.cymru/kaldi/language_corpus

echo "---- Downloading testing audio.... ----"
wget -P ${audio_data} -N -q -nd -c -e robots=off -r -np ${DATA_URL}/${testset_name}.tar.gz || \
 { echo "WGET error"'!' ; exit 1 ; }
echo "---- Finished downloading testing audio ----"

tar -zxf ${audio_data}/${testset_name}.tar.gz 

source ./local/downsample.sh $audio_data

rm $audio_data/*.tar.gz

