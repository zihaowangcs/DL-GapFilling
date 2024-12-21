#!/bin/bash

if [ $# -lt 1 ]; then
    echo "<data name>"
    exit 1
fi

data_name=$1;shift

#fastq-dump $data_name --split-3 --gzip -O ./
parallel-fastq-dump -t 12 -s $data_name --split-3 --gzip -O ./

mv ${data_name}_1.fastq.gz gap_gene_001.fastq.gz
mv ${data_name}_2.fastq.gz gap_gene_002.fastq.gz
