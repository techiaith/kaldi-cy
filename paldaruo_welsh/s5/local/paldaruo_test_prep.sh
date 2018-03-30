#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


# Check if the executables needed for this script are present in the system
command -v git-lfs >/dev/null 2>&1 ||\
 { echo "\"git lfs\" is needed but not found"'!'; exit 1; }

DATA_URL=http://techiaith.cymru/kaldi/test_sets

testcorpus_audio_rootdir=$1
testcorpus_name=$2

test_audio_dir=$3
sample_rate=$4

echo $testcorpus_audio_rootdir
echo $test_audio_dir

if [ ! -d $testcorpus_audio_rootdir/$testcorpus_name ] ; then

	mkdir -p $testcorpus_audio_rootdir/$testcorpus_name

	echo "---- Downloading ${testcorpus_name} test set ----"
	wget -P ${testcorpus_audio_rootdir}/${testcorpus_name} -N -q -nd -c -e robots=off -r -np ${DATA_URL}/${testcorpus_name}.tar.gz || \
 		{ echo "WGET error"'!' ; exit 1 ; }
	echo "---- Finished downloading testing audio ----"

	cd ${testcorpus_audio_rootdir}/${testcorpus_name}
	tar -zxf ${testcorpus_audio_rootdir}/${testcorpus_name}/${testcorpus_name}.tar.gz 
	cd -

fi

if [ ! -d $test_audio_dir ] ; then

	echo "--- Downsample ---"
	source ./local/downsample.sh $testcorpus_audio_rootdir/$testcorpus_name $test_audio_dir $sample_rate
	cp $testcorpus_audio_rootdir/$testcorpus_name/metadata.csv $test_audio_dir
	cp $testcorpus_audio_rootdir/$testcorpus_name/samples.txt $test_audio_dir

fi

