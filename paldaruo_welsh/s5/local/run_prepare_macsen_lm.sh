#!/bin/bash

. ./path.sh || exit 1
. ./cmd.sh || exit 1

# Usage: 
# $ ./local/run_prepare_lm.py 
#
github_url='https://github.com/techiaith/macsen/trunk/client/modules/cy/'
corpustext_dir=$LANGUAGEMODEL_DATA_ROOT
corpustext_file=corpus.txt   #macsen_data.txt 
lm_order=6

lexicon_dir=$KALDI_LEXICON_ROOT
kaldi_data_dir=$KALDI_DATA_ROOT
kaldi_local_data_dir=$KALDI_DATA_LOCAL_ROOT
languagemodels_dir=$KALDI_DATA_LOCAL_ROOT/lang_model


echo
echo "===== CREATING LANGUAGE MODEL ====="
echo

echo "corpustext_dir : ${corpustext_dir}"
echo "languagemodels_dir : ${languagemodels_dir}"

rm -rf $corpustext_dir
rm -rf $languagemodels_dir


echo "Fetching texts from Macsen source repository"
echo $data_dir
svn checkout $github_url $corpustext_dir

rm -rf $corpustext_dir/.svn
find $corpustext_dir ! -name '*.txt' -exec rm -f {} +

echo "Collecting text files..."
cat $corpustext_dir/*.txt | sed s/?// > $corpustext_dir/$corpustext_file 


echo "Preparing language model..."
./local/paldaruo_lm_prep.py -d $corpustext_dir -f $corpustext_file -l $kaldi_local_data_dir -o $lm_order -x $lexicon_dir || exit 1;
utils/format_lm.sh $kaldi_data_dir/lang $kaldi_local_data_dir/tmp/lm.arpa.gz $lexicon_dir/lexicon.txt $languagemodels_dir || exit 1;

rm -rf $kaldi_local_data_dir/tmp

tar -zcvf kaldi_lang_model.tar.gz -C $languagemodels_dir .

echo "Language model written to ${languagemodels_dir}"
tree $languagemodels_dir

echo "Language model in ${languagemodels_dir} also compressed to kaldi_lang_model.tar.gz"

