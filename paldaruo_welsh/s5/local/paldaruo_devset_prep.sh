#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

audio_data=$1
devset_name=$2

DATA_URL=http://techiaith.cymru/kaldi/speech_corpora

echo "---- Downloading devset audio.... ----"
wget -P ${audio_data} -N -q -nd -c -e robots=off -r -np ${DATA_URL}/${devset_name}.tar.gz || \
 { echo "WGET error"'!' ; exit 1 ; }
echo "---- Finished downloading devset audio ----"

tar -zxf ${audio_data}/${devset_name}.tar.gz 

source ./local/downsample.sh $audio_data

rm $audio_data/*.tar.gz

