#!/bin/bash

# defines the "DATA_ROOT" variable - the location to store data 
source ./path.sh

DATA_SRC="http://techiaith.cymru/corpws/Paldaruo/"

source utils/parse_options.sh

# Check if the executables needed for this script are present in the system
command -v wget >/dev/null 2>&1 ||\
 { echo "\"wget\" is needed but not found"'!'; exit 1; }

echo "--- Starting data download (may take some time) ..."
wget -P ${DATA_ROOT} -N -nd -c -e robots=off -A csv,txt,zip -r -np ${DATA_SRC} || \
 { echo "WGET error"'!' ; exit 1 ; }
 

echo "--- Starting archives extraction ..."
for a in ${DATA_ROOT}/*.zip; do
  unzip -d ${DATA_ROOT} $a
done

rm -rf ${DATA_ROOT}/*.zip

source ./local/downsample.sh

