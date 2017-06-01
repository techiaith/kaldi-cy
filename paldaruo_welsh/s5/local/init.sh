source ./path.sh

mkdir -p $DATA_ROOT/train
mkdir -p $DATA_ROOT/test

mkdir -p $KALDI_LEXICON_ROOT

mkdir -p $KALDI_DATA_ROOT/train
mkdir -p $KALDI_DATA_ROOT/test

ln -s /usr/local/src/kaldi/egs/wsj/s5/utils utils
ln -s /usr/local/src/kaldi/egs/wsj/s5/steps steps

