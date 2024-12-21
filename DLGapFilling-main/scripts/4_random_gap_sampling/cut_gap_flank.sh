#!/bin/bash
if [ $# -lt 2 ]; then
	echo "Usage: $(basename $0) <out fixed dir path> <draft fasta path>"
	exit 1
fi

out_dir=$1;shift
draft_assembly=$1;shift

bedtools getfasta -fi ${draft_assembly} -bed ${out_dir}/gene-scaffolds_fixed_gaps_flanks_with_both.bed > ${out_dir}/gene-scaffolds_fixed_gaps_flanks_with_both.fa
bedtools getfasta -fi ${draft_assembly} -bed ${out_dir}/gene-scaffolds_unfixed_gaps_flanks_with_both.bed > ${out_dir}/gene-scaffolds_unfixed_gaps_flanks_with_both.fa
