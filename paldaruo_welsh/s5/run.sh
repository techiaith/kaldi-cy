#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

#/
#/
#/ Usage : ./run.sh
#/ Description : Run the entire recipe for training speech recognition using the
#/               audio files from the paldaruo corpus.  
#/ Options: 
#/     --help: Display this help message
#/
#/
usage() { grep '^#/' "$0" | cut -c4- ; exit 0; }
expr "$*" : ".*--help" > /dev/null && usage

. ./path.sh || exit 1
. ./cmd.sh || exit 1


echo "==== AUDIO DATA PATHS ===="
echo "TRAIN_AUDIO_ROOT=${TRAIN_AUDIO_ROOT}"
echo "DEV_AUDIO_ROOT=${DEV_AUDIO_ROOT}"
echo "TEST_AUDIO_ROOT=${TEST_AUDIO_ROOT}"
echo
echo "==== OUTPUT PATHS ===="
echo "OUTPUT_ROOT=${OUTPUT_ROOT}"
echo "MFCC_ROOT=${MFCC_ROOT}"
echo "EXP_ROOT=${EXP_ROOT}"
echo "KALDI_DATA_ROOT=${KALDI_DATA_ROOT}"
echo "KALDI_DATA_LOCAL_ROOT=${KALDI_DATA_LOCAL_ROOT}"
echo "KALDI_LEXICON_ROOT=${KALDI_LEXICON_ROOT}"
echo "TGT_MODELS_OUTPUT=${TGT_MODELS_OUTPUT}"


if [ ! -L steps ] && [ ! -L utils ] ; then
	echo
	echo "===== SETTING UP KALDI SUPPORT SCRIPT SYMLINKS AND PATH ====="
	echo
	ln -s ../../wsj/s5/steps steps 
	ln -s ../../wsj/s5/utils utils

	echo "Setting up PATH environment variable"
        if uname -a | grep 64 >/dev/null; then
               	sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
        else
               	sdir=$KALDI_ROOT/tools/srilm/bin/i686
        fi
	
        if [ -f $sdir/ngram-count ] ; then
		if [[ ! :$PATH: == *":$sdir:"* ]]; then
                	echo "Adding SRILM language modelling tool from $sdir to PATH"
                	export PATH=$PATH:$sdir
		fi
        else
               	echo "SRILM toolkit is probably not installed. Instructions: tools/install_srilm.sh"
               	exit 1
        fi
fi

. utils/parse_options.sh || exit 1
[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; } 

cpus=`nproc`
if (($cpus > 1)); then
	cpus=`expr $cpus / 2`
fi

nj=$cpus

stage=0

paldaruo_audio=$TRAIN_AUDIO_ROOT
test_audio=$TEST_AUDIO_ROOT
testset_name='Macsen'

data_dir=$KALDI_DATA_ROOT
lexicon_dir=$KALDI_LEXICON_ROOT
languagemodels_dir=$KALDI_DATA_LOCAL_ROOT
lm_order=3 # language model order (n-gram quantity) - 1 is enough for digits grammar

mfcc_dir=$MFCC_ROOT
exp_dir=$EXP_ROOT


if [ ! -d $paldaruo_audio ] ; then 
	echo
	echo "===== CHECKING PALDARUO AUDIO DATA ====="
	echo
	echo "Paldaruo audio files are not present. "
	echo "Will attempt to download"
	echo
	./local/paldaruo_data_prep.sh $paldaruo_audio || exit 1
fi



if [ ! -d $test_audio ] ; then
	echo
	echo "===== CHECKING AUDIO FOR TESTING MODELS ====="
	echo
	echo "Audio files for testing are not present. "
	echo "Will attempt to download"
	echo
	./local/paldaruo_test_prep.sh $test_audio $testset_name || exit 1
fi



if [ ! -d $data_dir ] ; then
	echo 
	echo "===== CHECKING KALDI TRAINING AND TEST SETUP ====="
	echo
	echo "Kaldi data directory not present. "
	echo "Creating spk2utt, utt2spk, wav.scp and text files "
	echo
	for x in train test
	do
		if [ "$x" == "train" ]; then
			source_audio=$paldaruo_audio
		else
			source_audio=$test_audio
		fi 
		./local/paldaruo_kaldi_prep.py -a $source_audio -d $data_dir -t $x
	done
fi


if [ ! -d $lexicon_dir ] ; then
	echo
	echo "===== CHECKING LEXICON SETUP ====="
	echo
	echo "Welsh pronunciation lexicon files are not present. "
	echo "Will attempt to download. "
	echo
	./local/paldaruo_lexicon_prep.sh $lexicon_dir
	./local/paldaruo_phones_prep.py -d $lexicon_dir
	utils/prepare_lang.sh $lexicon_dir "<UNK>" $data_dir/local/lang $data_dir/lang
fi


if [ ! -f $languagemodels_dir/corpus.txt ] ; then
	echo
	echo "===== CHECKING LANGUAGE MODELLING SETUP ====="
	echo
	echo "Language models not present. "
	echo "Will attempt to create"
	./local/paldaruo_lm_prep.py -t $test_audio -l $languagemodels_dir -o $lm_order -x $lexicon_dir
	utils/format_lm.sh $data_dir/lang $languagemodels_dir/tmp/lm.arpa.gz $lexicon_dir/lexicon.txt $data_dir/lang_test || exit 1;
fi


echo
echo "===== PREPARING ACOUSTIC DATA ====="
echo
for x in train test 
do
	utils/utt2spk_to_spk2utt.pl $data_dir/$x/utt2spk > $data_dir/$x/spk2utt
done
echo "==================================="


if [ ! -d $mfcc_dir ] ; then 
	echo
	echo "===== FEATURES EXTRACTION ====="
	echo
	for x in train test
	do
		echo
		echo "== " $x " =="
		echo
		utils/validate_data_dir.sh --no-feats $data_dir/$x || exit 1;
		utils/fix_data_dir.sh $data_dir/$x || exit 1;
		steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" $data_dir/$x $exp_dir/make_mfcc/$x $mfcc_dir || exit 1;
		steps/compute_cmvn_stats.sh $data_dir/$x $exp_dir/make_mfcc/$x $mfcc_dir || exit 1;
	done
	echo "==============================="
fi


if [ $stage -le 1 ]; then
	echo
	echo "===== MONOPHONE TRAINING ====="
	echo
	echo "Start monophone training"
	echo
	steps/train_mono.sh --nj $nj --cmd "$train_cmd" $data_dir/train $data_dir/lang $exp_dir/mono  || exit 1;
	echo
	echo "Monophone training done."
	echo
	echo "Decoding test sets using monophone models."
	echo
	utils/mkgraph.sh --mono $data_dir/lang_test $exp_dir/mono $exp_dir/mono/graph || exit 1;
	steps/decode.sh --config conf/decode.config --nj 1 --cmd "$decode_cmd" $exp_dir/mono/graph $data_dir/test $exp_dir/mono/decode_test || exit 1;
	echo
	echo "Monophone deooding done"
	echo
	echo "========================="
	echo
fi


if [ $stage -le 2 ]; then
	echo
	echo "===== TRIPHONE TRAINING ====="
	echo
	echo "Starting triphone training"
	echo
	steps/align_si.sh --nj $nj --cmd "$train_cmd" $data_dir/train $data_dir/lang $exp_dir/mono $exp_dir/mono_ali || exit 1;
	steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 $data_dir/train $data_dir/lang $exp_dir/mono_ali $exp_dir/tri1 || exit 1;
	echo
	echo "Triphone training done"
	echo
	echo "Decoding the test set using triphone models"
	echo
	utils/mkgraph.sh $data_dir/lang_test $exp_dir/tri1 $exp_dir/tri1/graph || exit 1;
	steps/decode.sh --config conf/decode.config --nj 1 --cmd "$decode_cmd" $exp_dir/tri1/graph $data_dir/test $exp_dir/tri1/decode_test || exit 1;
	echo
	echo "Triphone decoding done"
	echo
	echo "============================="
	echo
fi


if [ $stage -le 3 ]; then
	echo 
	echo "====== TRIPHONE + LDA and MLLT TRAINING ====="
	echo
	echo "Starting triphone LDA and MLLT training"
	echo
	steps/align_si.sh  --nj $nj --cmd "$train_cmd" $data_dir/train $data_dir/lang $exp_dir/tri1 $exp_dir/tri1_ali || exit 1;
	steps/train_lda_mllt.sh --cmd "$train_cmd" 2000 11000 $data_dir/train $data_dir/lang $exp_dir/tri1_ali $exp_dir/tri2 || exit 1;
	echo
	echo "Triphone LDA and MLLT training done"
	echo
	echo "Decoding the test set using triphone LDA and MLLT models"
	echo
	utils/mkgraph.sh $data_dir/lang_test  $exp_dir/tri2 $exp_dir/tri2/graph || exit 1;
	steps/decode.sh --nj 1 --cmd "$decode_cmd" $exp_dir/tri2/graph $data_dir/test $exp_dir/tri2/decode_test || exit 1;
	echo
	echo "LDA+MLLT decoding done."
	echo
	echo "============================================="
	echo
fi


if [ $stage -le 4 ]; then
	echo
	echo "====== TRIPHONE + LDA and MLLT + SAT and FMLLR TRAINING ====="
	echo
	echo "Starting triphone SAT and FMLLR training"
	echo
	steps/align_si.sh  --nj $nj --cmd "$train_cmd" $data_dir/train $data_dir/lang $exp_dir/tri2 $exp_dir/tri2_ali || exit 1;
	steps/train_sat.sh --cmd "$train_cmd" 2000 11000 $data_dir/train $data_dir/lang $exp_dir/tri2_ali $exp_dir/tri3 || exit 1;
	echo
	echo "Triphone SAT and FMLLR training done"
	echo
	echo "Decoding the test set using triphone SAT and FMLLR models"
	echo
	utils/mkgraph.sh $data_dir/lang_test  $exp_dir/tri3 $exp_dir/tri3/graph || exit 1;
	steps/decode_fmllr.sh --nj 1 --cmd "$decode_cmd" $exp_dir/tri3/graph $data_dir/test $exp_dir/tri3/decode_test || exit 1;
	echo
	echo "SAT and FMLLR decoding done."
	echo
	echo "============================================="
	echo
fi


if [ $stage -le 5 ]; then
	echo
	echo "====== CLEANUP AND FILTER DATA WITH BAD ALIGNMENTS ====== "
	echo
	steps/cleanup/find_bad_utts.sh --nj $nj --cmd "$train_cmd" $data_dir/train $data_dir/lang $exp_dir/tri3 $exp_dir/tri3_cleanup
	head  $exp_dir/tri3_cleanup/all_info.sorted.txt
	echo
	echo "============================================="
	echo
fi


for x in $exp_dir/*/decode*; do [ -d $x ] && echo && echo $x && grep WER $x/wer_* | utils/best_wer.sh; done


echo
echo "===== EXPORTING MODELS FOR DEPLOYMENT ====="
echo
model_type='tri3'
local/export_models.sh $TGT_MODELS_OUTPUT $model_type $exp_dir
echo
echo "============================================="
echo

