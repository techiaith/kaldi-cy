#!/bin/bash

source ./path.sh

AUDIO_DIRS=$(find $TEST_ROOT -maxdepth 1 -type d)
for a in $AUDIO_DIRS; do
	echo $a
	mkdir -p $a/48kHz

	WAV_FILES=$(find $a -maxdepth 1 -type f -name '*.wav')
	for w in $WAV_FILES; do
		mv $w $a/48kHz/
	done

	WAV_FILES_48kHz=$(find $a/48kHz -maxdepth 1 -type f -name '*.wav')
	for wf in $WAV_FILES_48kHz; do
		echo $wf
		filename=$(basename "$wf")
		sox $wf -c 1 -r 16000 $a/$filename
	done

done
