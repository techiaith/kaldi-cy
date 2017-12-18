#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Check if the executables needed for this script are present in the system
command -v git-lfs >/dev/null 2>&1 ||\
 { echo "\"git lfs\" is needed but not found"'!'; exit 1; }

audio_data=$1

DATA_SRC="https://git.techiaith.bangor.ac.uk/Data-Porth-Technolegau-Iaith/Corpws-Paldaruo"
DATA_VERSION="v4.0"

echo "--- Starting data download from public repository (may take some time) ..."
git -c http.sslVerify=false lfs clone --branch ${DATA_VERSION} --depth 1 ${DATA_SRC} ${audio_data} ||\
 { echo "git lfs clone error"'!' ; exit 1 ; }

echo "--- Extract wav files from zip archives ---"
for a in ${audio_data}/audio/wav/*.zip; do
  unzip -d ${audio_data} $a
done
rm -rf ${audio_data}/audio

echo "--- Downsample to 16kHz ---"
source ./local/downsample.sh $audio_data

