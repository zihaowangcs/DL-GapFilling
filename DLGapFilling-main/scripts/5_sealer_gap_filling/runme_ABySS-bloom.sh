#!/bin/bash

if [ $# -lt 3 ]; then
	echo "Usage: $(basename $0) <read directory> <DGCNet read_dir> <outpath>"
	exit 1
fi

mkdir -p ./log
read_dir=$1;shift
dgcnet_read_dir=$1;shift
outpath=$1;shift

for i in {45..105..10}
  do
    nohup /usr/bin/time -pv ./abyss-bloom.slurm $i $outpath \
    ${read_dir}/gap_gene_001.fastq.gz \
    ${read_dir}/gap_gene_002.fastq.gz \
    ${dgcnet_read_dir}/set1_gappredict.fasta \
    ${dgcnet_read_dir}/set2_gappredict.fasta \
    &> ./log/k$i.log &
  done
