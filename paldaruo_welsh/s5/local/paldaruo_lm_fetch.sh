#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

dest_dir=$1
lm_name=$2

DATA_URL=http://techiaith.cymru/kaldi/language_models

mkdir -p $dest_dir

echo "---- Downloading language model.... ----"
wget -P ${dest_dir} -N -q -nd -c -e robots=off -r -np ${DATA_URL}/${lm_name}.tar.gz || { echo "WGET Error"'!' ; exit 1 ; }
echo "---- Finished downloading language model ----"

echo "---- Unzipping ${lm_name}.tar.gz  in ${dest_dir} ----"
cd ${dest_dir}
tar -zxf ${lm_name}.tar.gz # -C ${dest_dir} 
cd -

rm ${dest_dir}/${lm_name}.tar.gz 

