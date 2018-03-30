#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

# Usage: 
# $ ./local/run_prepare_lm.sh <data dir> <data file> <n order>
#

data_dir=$1    #$LANGUAGEMODEL_DATA_ROOT
data_file=$2 
lm_order=$3
lexicon_dir=$KALDI_LEXICON_ROOT
kaldi_data_dir=$KALDI_DATA_ROOT
kaldi_local_data_dir=$KALDI_DATA_LOCAL_ROOT
languagemodels_dir=$KALDI_DATA_LOCAL_ROOT/lang_model

echo
echo "===== CREATING LANGUAGE MODEL ====="
echo

rm -rf $languagemodels_dir

./local/paldaruo_lm_prep.py -d $data_dir -f $data_file -l $kaldi_local_data_dir -o $lm_order -x $lexicon_dir || exit 1;
utils/format_lm.sh $kaldi_data_dir/lang $kaldi_local_data_dir/tmp/lm.arpa.gz $lexicon_dir/lexicon.txt $languagemodels_dir || exit 1;

rm -rf $kaldi_local_data_dir/tmp

tar -zcvf kaldi_lang_model.tar.gz -C $languagemodels_dir .

echo "Language Models in $languagemodels_dir compressed to kaldi_lang_model.tar.gz"

