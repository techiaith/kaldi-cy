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


echo "==== AUDIO DATA FROM path.sh ===="
echo "TRAIN_AUDIO_ROOT=${TRAIN_AUDIO_ROOT}"
echo "TEST_AUDIO_ROOT=${TEST_AUDIO_ROOT}"
echo
echo "==== OUTPUT PATHS FROM path.sh ===="
echo "OUTPUT_ROOT=${OUTPUT_ROOT}"
echo "MFCC_ROOT=${MFCC_ROOT}"
echo "EXP_ROOT=${EXP_ROOT}"
echo "KALDI_DATA_ROOT=${KALDI_DATA_ROOT}"
echo "KALDI_DATA_LOCAL_ROOT=${KALDI_DATA_LOCAL_ROOT}"
echo "KALDI_LEXICON_ROOT=${KALDI_LEXICON_ROOT}"
echo "TGT_MODELS_OUTPUT=${TGT_MODELS_OUTPUT}"


# === Locally defined paths and variables ============================================================

stage=0 # which stage to start at
domain='macsen_v2.0' # 'dictation', 'macsen_v1.0' or 'macsen_v2.0'
sample_rate=16000

testset_name='macsen_v1.0'  # usually = $domain
ignore_testset=false # if true, then we won't be testing the new models. Not recommended. 

corpus_audio=$CORPUS_AUDIO_ROOT
testcorpus_audio=$TESTCORPUS_AUDIO_ROOT

train_audio=$TRAIN_AUDIO_ROOT/$sample_rate
test_audio=$TEST_AUDIO_ROOT/$sample_rate

data_dir=$KALDI_DATA_ROOT
local_data_dir=$KALDI_DATA_LOCAL_ROOT
lexicon_dir=$KALDI_LEXICON_ROOT

languagemodel_dir=$KALDI_DATA_LOCAL_ROOT/lang_model
lm_name=$domain

mfcc_dir=$MFCC_ROOT
exp_dir=$EXP_ROOT

cpus=`nproc`
if (($cpus > 1)); then
	cpus=`expr $cpus / 2`
fi

nj=$cpus


# ====================================================================================================


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


echo
echo "===== CHECKING PALDARUO AUDIO DATA ====="
echo
./local/paldaruo_data_prep.sh $corpus_audio $train_audio $sample_rate || exit 1


if [ "$ignore_testset" == false ]; then
	echo
	echo "===== CHECKING AUDIO FOR TESTING MODELS ====="
	echo
	echo "Audio files for testing are not present. "
	echo "Will attempt to download"
	echo
	./local/paldaruo_test_prep.sh $testcorpus_audio $testset_name $test_audio $sample_rate || exit 1	
fi


echo 
echo "===== CHECKING KALDI TRAINING AND TEST SETUP ====="
echo
if [ ! -d $data_dir ] ; then
	echo "Kaldi data directory not present. "
	echo "Creating spk2utt, utt2spk, wav.scp and text files "
	echo
	./local/paldaruo_kaldi_prep.py -a $train_audio -d $data_dir -t train
	utils/utt2spk_to_spk2utt.pl $data_dir/train/utt2spk > $data_dir/train/spk2utt

	echo
	echo "Kaldi test data directory not present. "
	echo "Creating test spk2utt, utt2spk, wav.scp and text files "
	echo
	if [ "$ignore_testset" == "false" ]; then
		./local/paldaruo_kaldi_prep.py -a $test_audio -d $data_dir -t test
		utils/utt2spk_to_spk2utt.pl $data_dir/test/utt2spk > $data_dir/test/spk2utt
	fi	
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
	echo
	echo "=================================="
fi



if [ ! -d $languagemodel_dir ] ; then
	echo 
	echo "===== PREPARING LANGUAGE MODEL SETUP ====="
	echo
	echo "Language models not present. Will fetch $lm_name "
	echo
	echo "./local/paldaruo_lm_fetch.sh ${languagemodel_dir} ${lm_name}"
	./local/paldaruo_lm_fetch.sh $languagemodel_dir $lm_name || exit 1;
	echo	
	echo "=========================================="
fi



if [ ! -d $mfcc_dir ] ; then 
	echo
	echo "===== FEATURES EXTRACTION ====="
	echo

	echo "--- Updating mfcc config ---"
	sed s/SAMPLERATE/$sample_rate/g $CONFIG_ROOT/mfcc.conf.template > $CONFIG_ROOT/mfcc.conf

	for x in train test
	do	
		if [ "$x" == "test" ] && [ "$ignore_testset" == "true" ] ; then
			continue
		fi
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
	utils/mkgraph.sh --mono $languagemodel_dir $exp_dir/mono $exp_dir/mono/graph || exit 1;
	echo
	echo "Monophone training done."
	echo
	if [ "$ignore_testset" == false ] ; then 
		echo "Decoding test sets using monophone models."
		echo
		steps/decode.sh --config conf/decode.config --nj 1 --cmd "$decode_cmd" $exp_dir/mono/graph $data_dir/test $exp_dir/mono/decode_test || exit 1;
		echo
		echo "Monophone deooding done"
		echo
	fi
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
	utils/mkgraph.sh $languagemodel_dir $exp_dir/tri1 $exp_dir/tri1/graph || exit 1;
	echo 
	echo "Triphone training done"
	echo
	if [ "$ignore_testset" == false ] ; then	
		echo "Decoding the test set using triphone models"
		echo
		steps/decode.sh --config conf/decode.config --nj 1 --cmd "$decode_cmd" $exp_dir/tri1/graph $data_dir/test $exp_dir/tri1/decode_test || exit 1;
		echo
		echo "Triphone decoding done"
		echo
	fi
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
	utils/mkgraph.sh $languagemodel_dir  $exp_dir/tri2 $exp_dir/tri2/graph || exit 1;
	echo
	echo "Triphone LDA and MLLT training done"
	echo
	if [ "$ignore_testset" == false ] ; then
		echo "Decoding the test set using triphone LDA and MLLT models"
		echo
		steps/decode.sh --nj 1 --cmd "$decode_cmd" $exp_dir/tri2/graph $data_dir/test $exp_dir/tri2/decode_test || exit 1;
		echo
		echo "LDA+MLLT decoding done."
		echo
	fi
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
	utils/mkgraph.sh $languagemodel_dir  $exp_dir/tri3 $exp_dir/tri3/graph || exit 1;
	echo
	echo "Triphone SAT and FMLLR training done"
	echo
	if [ "$ignore_testset" == false ] ; then
		echo "Decoding the test set using triphone SAT and FMLLR models"
		echo
		steps/decode_fmllr.sh --nj 1 --cmd "$decode_cmd" $exp_dir/tri3/graph $data_dir/test $exp_dir/tri3/decode_test || exit 1;
		echo
		echo "SAT and FMLLR decoding done."
		echo
	fi
	echo "============================================="
	echo
fi


if [ $stage -le 5 ]; then
	echo
	echo "====== CLEANUP AND FILTER DATA WITH BAD ALIGNMENTS ====== "
	echo
	steps/cleanup/find_bad_utts.sh --nj $nj --cmd "$train_cmd" $data_dir/train $data_dir/lang $exp_dir/tri3 $exp_dir/tri3_cleanup
	head  $exp_dir/tri3_cleanup/all_info.sorted.txt
	#cp $exp_dir/tri3_cleanup/all_info.sorted.txt $corpus_audio
	echo
	echo "============================================="
	echo
fi


if [ "$ignore_testset" == false ] ; then
	for x in $exp_dir/*/decode*; do [ -d $x ] && echo && echo $x && grep WER $x/wer_* | utils/best_wer.sh; done
fi


echo
echo "===== EXPORTING MODELS FOR DEPLOYMENT ====="
echo
model_type='tri3'
local/export_models.sh $TGT_MODELS_OUTPUT $model_type $exp_dir
echo
echo "============================================="
echo


