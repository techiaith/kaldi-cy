#!/bin/bash

. ./path.sh || exit 1

draw-tree data/lang/phones.txt exp/mono/tree | dot -Tps -Gsize=8,10.5 | ps2pdf - exp/mono/tree.pdf

draw-tree data/lang/phones.txt exp/tri1/tree | dot -Tps -Gsize=8,10.5 | ps2pdf - exp/tri1/tree.pdf
