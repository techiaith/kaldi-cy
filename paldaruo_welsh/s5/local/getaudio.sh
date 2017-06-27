#!/bin/bash

# defines the "DATA_ROOT" variable - the location to store data 
source ./path.sh

DATA_SRC="https://git.techiaith.bangor.ac.uk/Data-Porth-Technolegau-Iaith/Corpws-Paldaruo"
DATA_VERSION="v3.0"

source utils/parse_options.sh

# Check if the executables needed for this script are present in the system
command -v git-lfs >/dev/null 2>&1 ||\
 { echo "\"git lfs\" is needed but not found"'!'; exit 1; }

echo "--- Starting data download (may take some time) ..."
git -c http.sslVerify=false lfs clone --branch ${DATA_VERSION} --depth 1 ${DATA_SRC} ${DATA_ROOT} ||\
 { echo "git lfs clone error"'!' ; exit 1 ; }

# Unzip
echo "--- Starting archives extraction ..."
for a in ${DATA_ROOT}/audio/wav/*.zip; do
  unzip -d ${DATA_ROOT} $a
done

rm -rf ${DATA_ROOT}/audio

source ./local/downsample.sh

