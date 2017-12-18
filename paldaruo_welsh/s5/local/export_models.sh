#!/bin/bash

# Copyright (c) 2016, Prifysgol Bangor University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
# WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
# MERCHANTABLITY OR NON-INFRINGEMENT.
# See the Apache 2 License for the specific language governing permissions and
# limitations under the License. #

trained_models=$1
model_type=$2
exp_dir=$3

rm -rf $trained_models
mkdir -p $trained_models/$model_type

echo "--- Exporting $model_type models to $trained_models/$model_type ..."

cp -f conf/mfcc.conf $trained_models/$model_type/mfcc.conf

cp -f $exp_dir/$model_type/graph/HCLG.fst $trained_models/$model_type/HCLG.fst
cp -f $exp_dir/$model_type/graph/words.txt $trained_models/$model_type/words.txt

cp -f $exp_dir/$model_type/final.mat $trained_models/$model_type/final.mat
cp -f $exp_dir/$model_type/final.mdl $trained_models/$model_type/final.mdl

