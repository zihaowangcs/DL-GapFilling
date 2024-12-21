#!/bin/bash
if [ $# -lt 4 ]; then
	echo "Usage: $(basename $0) <DGCNet lib directory> <FASTA for a single gap> <FASTQ for a single gap> <output directory>"
	exit 1
fi

lib_dir=$1; shift
fasta=$1; shift
fastq=$1; shift
outdir=$1; shift
if [ $# -gt 0 ]; then
  batch_size=$1;shift
  embedding_dim=$1;shift
  latent_dim=$1;shift
  cnn_filter=$1;shift
fi

if [ -z "$batch_size" ]; then
        python ${lib_dir}/GapPredict.py -fa ${fasta} -fq ${fastq} -o ${outdir}
      else
        python ${lib_dir}/GapPredict.py -fa ${fasta} -fq ${fastq} -o ${outdir} -bs ${batch_size} -ed ${embedding_dim} -hu ${latent_dim} -fl ${cnn_filter}
fi