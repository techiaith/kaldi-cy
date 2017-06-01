export KALDI_ROOT=`pwd`/../../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh

export PATH=$PWD/utils/:$KALDI_ROOT/tools/openfst/bin/:$KALDI_ROOT/src/fstbin/:$KALDI_ROOT/src/gmmbin/:$KALDI_ROOT/src/featbin/:$KALDI_ROOT/src/lm/:$KALDI_ROOT/src/sgmmbin/:$KALDI_ROOT/src/sgmm2bin/:$KALDI_ROOT/src/fgmmbin/:$KALDI_ROOT/src/latbin/$PWD:$PATH
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh

# data will be stored in:
export DATA_ROOT=`pwd`/paldaruo_audio   
export TEST_ROOT=`pwd`/test_audio

export KALDI_DATA_ROOT=`pwd`/data
export KALDI_DATA_LOCAL_ROOT=$KALDI_DATA_ROOT/local 
export KALDI_LEXICON_ROOT=$KALDI_DATA_LOCAL_ROOT/dict

export TGT_MODELS=`pwd`/trained_models

# Make sure that MITLM shared libs are found by the dynamic linker/loader
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/tools/mitlm-svn/lib

# Needed for "correct" sorting
export LC_ALL=C

