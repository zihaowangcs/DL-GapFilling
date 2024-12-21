#!/bin/bash

if [ $# -ne 2 ]; then
	echo "Usage: $(basename $0) <Draft scaffolds FASTA> <Bloom filter directory>"
	exit 1
fi

set -x
set -e

draft=$1; shift
bloom_filters=$1; shift
draft_base=gene-scaffolds

/usr/bin/time -pv abyss-sealer -v -S $draft \
	-t $draft_base-sealed-trace.txt \
	-o $draft_base'.sealer' \
	-L 150 \
	-j 48 \
	-P 10  \
	-k 45 --input-bloom=<(gunzip -c ${bloom_filters}/k45'.bloom.gz') \
	-k 55 --input-bloom=<(gunzip -c ${bloom_filters}/k55'.bloom.gz') \
	-k 65 --input-bloom=<(gunzip -c ${bloom_filters}/k65'.bloom.gz') \
	-k 75 --input-bloom=<(gunzip -c ${bloom_filters}/k75'.bloom.gz') \
	-k 85 --input-bloom=<(gunzip -c ${bloom_filters}/k85'.bloom.gz') \
	-k 95 --input-bloom=<(gunzip -c ${bloom_filters}/k95'.bloom.gz') \
	-k 105 --input-bloom=<(gunzip -c ${bloom_filters}/k105'.bloom.gz')
	
	

### EOF ###
