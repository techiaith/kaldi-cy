#!/bin/bash

audio_corpus_dir=$1
audio_dir=$2
sample_rate=$3

rm -rf $audio_dir

AUDIO_DIRS=$(find $audio_corpus_dir -maxdepth 1 -type d)
for a in $AUDIO_DIRS; do
	echo $a
	#mkdir -p $a/orig

	#WAV_FILES=$(find $a -maxdepth 1 -type f -name '*.wav')
	#for w in $WAV_FILES; do
	#	mv $w $a/orig/
	#done

	WAV_FILES=$(find $a -maxdepth 1 -type f -name '*.wav')
	for wf in $WAV_FILES; do
		uid=$(basename "$(dirname -- "$wf")")
		filename=$(basename "$wf")
		mkdir -p $audio_dir/$uid
		echo $audio_dir/$uid/$filename
		sox $wf -c 1 -r $sample_rate $audio_dir/$uid/$filename
	done

done

