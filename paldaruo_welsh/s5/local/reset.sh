#!/bin/bash
. ./path.sh || exit 1

rm -rf ${TRAIN_AUDIO_ROOT}
rm -rf ${TEST_AUDIO_ROOT}

rm -rf ${OUTPUT_ROOT}

