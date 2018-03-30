export KALDI_ROOT=`pwd`/../../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh

export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin/:$PWD:$PATH

[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

export CONFIG_ROOT=$PWD/conf

##
export AUDIO_ROOT=${HOME}/kaldi-cy/paldaruo_welsh/audio
mkdir -p "${AUDIO_ROOT}"

export CORPUS_AUDIO_ROOT=$AUDIO_ROOT/corpus
export TESTCORPUS_AUDIO_ROOT=$AUDIO_ROOT/testcorpus
export TRAIN_AUDIO_ROOT=$AUDIO_ROOT/train
export TEST_AUDIO_ROOT=$AUDIO_ROOT/test

##
export OUTPUT_ROOT=${HOME}/kaldi-cy/paldaruo_welsh/output
mkdir -p "${OUTPUT_ROOT}"

export MFCC_ROOT=$OUTPUT_ROOT/mfcc
export EXP_ROOT=$OUTPUT_ROOT/exp

export KALDI_DATA_ROOT=$OUTPUT_ROOT/data
export KALDI_DATA_LOCAL_ROOT=$KALDI_DATA_ROOT/local
export KALDI_LEXICON_ROOT=$KALDI_DATA_LOCAL_ROOT/dict

export TGT_MODELS_OUTPUT=$OUTPUT_ROOT/trained_models

# 
export LANGUAGEMODEL_DATA_ROOT=${HOME}/kaldi-cy/text


# Needed for "correct" sorting
export LC_ALL=C

