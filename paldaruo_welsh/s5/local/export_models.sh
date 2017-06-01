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

rm -rf trained_models

mkdir -p trained_models
mkdir -p trained_models/tri2b_mmi

echo "--- Exporting models to ./trained_models ..."

cp -f conf/mfcc.conf trained_models/tri2b_mmi/mfcc.conf

cp -f exp/tri2b/graph/HCLG.fst trained_models/tri2b_mmi/HCLG.fst
cp -f exp/tri2b/graph/words.txt trained_models/tri2b_mmi/words.txt

cp -f exp/tri2b_mmi/final.mat trained_models/tri2b_mmi/final.mat
cp -f exp/tri2b_mmi/final.mdl trained_models/tri2b_mmi/final.mdl

