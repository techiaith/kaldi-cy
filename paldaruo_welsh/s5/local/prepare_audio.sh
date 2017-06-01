#!/bin/bash

rm -rf $KALDI_DATA_ROOT/train/*
rm -rf $KALDI_DATA_ROOT/test/*

./local/make_speaker2gender.py
./local/make_utt2spk.py
./local/make_wavscp.py
./local/make_text.py
