#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Check if the executables needed for this script are present in the system
command -v git-lfs >/dev/null 2>&1 ||\
 { echo "\"git lfs\" is needed but not found"'!'; exit 1; }

corpus_data=$1
audio_data=$2
sample_rate=$3

if [ ! -d $corpus_data ] ; then

	mkdir -p $corpus_data

	DATA_SRC="https://git.techiaith.bangor.ac.uk/Data-Porth-Technolegau-Iaith/Corpws-Paldaruo"
	DATA_VERSION="v4.0"

	echo "--- Starting data download from public repository (may take some time) ..."
	git -c http.sslVerify=false lfs clone --branch ${DATA_VERSION} --depth 1 ${DATA_SRC} ${corpus_data} || \
	 { echo "git lfs clone error"'!' ; exit 1 ; }

	echo "--- Extract wav files from zip archives ---"
	for a in ${corpus_data}/audio/wav/*.zip; do
	  unzip -d ${corpus_data} $a
	done

	rm -rf ${corpus_data}/audio
fi

if [ ! -d $audio_data ] ; then

	echo "--- Downsample ---"
	source ./local/downsample.sh $corpus_data $audio_data $sample_rate
	cp $corpus_data/metadata.csv $audio_data
	cp $corpus_data/samples.txt $audio_data

fi

echo "Checking for $corpus_data/all_info.sorted.txt"
if [ -f $corpus_data/all_info.sorted.txt ] ; then
	echo "--- Cleaning up audio data ---"
	./local/paldaruo_corpus_cleanup.py $audio_data $corpus_data/all_info.sorted.txt
fi

