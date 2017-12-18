export KALDI_ROOT=`pwd`/../../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh

export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin/:$PWD:$PATH

[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh


export OUTPUT_ROOT=${HOME}/kaldi-cy/output
mkdir -p "${OUTPUT_ROOT}"

export TRAIN_AUDIO_ROOT=`pwd`/paldaruo_audio
# export training set root
export TEST_AUDIO_ROOT=`pwd`/test_audio
export DEV_AUDIO_ROOT=`pwd`/dev_audio

export MFCC_ROOT=$OUTPUT_ROOT/mfcc
export EXP_ROOT=$OUTPUT_ROOT/exp

export KALDI_DATA_ROOT=$OUTPUT_ROOT/data
export KALDI_DATA_LOCAL_ROOT=$KALDI_DATA_ROOT/local
export KALDI_LEXICON_ROOT=$KALDI_DATA_LOCAL_ROOT/dict

export TGT_MODELS_OUTPUT=$OUTPUT_ROOT/trained_models

# Needed for "correct" sorting
export LC_ALL=C

