#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: $(basename $0) <reference path>"
	exit 1
fi

reference=$1;shift
bwa index $reference

out_path=$(pwd)

gap_class=${out_path}/out/fixed/

cd ${gap_class}

for directory in */; do
  gap_id=$(echo $directory | sed 's/\///g')
  base_path=$gap_class$gap_id
  raw_fasta=$base_path/$gap_id.fasta

  flanks_path=$base_path/flanks
  mkdir -p $flanks_path
  flanks_file=$flanks_path/$gap_id'_'flanks.fasta
  left_flank_file=$flanks_path/$gap_id'_'left_flank.fasta
  right_flank_file=$flanks_path/$gap_id'_'right_flank.fasta
  head -4 $raw_fasta > $flanks_file
  head -2 $raw_fasta > $left_flank_file
  head -4 $raw_fasta | tail -2 > $right_flank_file

  align_id=$gap_id

  bwa_path=$base_path/bwa
  mkdir -p $bwa_path
  bam_file=$bwa_path/$align_id.bam
  sorted_bam_file=$bwa_path/$align_id.sorted.bam
  bwa mem -t 20 -x intractg $reference $flanks_file 2>$bwa_path/bwa_mem.log.txt | samtools view -bS - > $bam_file
  samtools sort $bam_file 1>$sorted_bam_file
  samtools index $sorted_bam_file

  bed_path=$base_path/bed
  mkdir -p $bed_path
  bed_file=$bed_path/$align_id'_'flanks.bed
  merged_bed_file=$bed_path/$align_id'_'merged_flanks.bed
  bedtools bamtobed -i $sorted_bam_file > $bed_file
  bedtools merge -i $bed_file -d 100000 > $merged_bed_file

  gap_flank_file=$base_path/$align_id'_'gap_flank_reference.fasta
  bedtools getfasta -fi $reference -bed $merged_bed_file > $gap_flank_file

done


gap_class=${out_path}/out/unfixed/

cd ${gap_class}

for directory in */; do
  gap_id=$(echo $directory | sed 's/\///g')
  base_path=$gap_class$gap_id
  raw_fasta=$base_path/$gap_id.fasta

  flanks_path=$base_path/flanks
  mkdir -p $flanks_path
  flanks_file=$flanks_path/$gap_id'_'flanks.fasta
  left_flank_file=$flanks_path/$gap_id'_'left_flank.fasta
  right_flank_file=$flanks_path/$gap_id'_'right_flank.fasta
  head -4 $raw_fasta > $flanks_file
  head -2 $raw_fasta > $left_flank_file
  head -4 $raw_fasta | tail -2 > $right_flank_file

  align_id=$gap_id

  bwa_path=$base_path/bwa
  mkdir -p $bwa_path
  bam_file=$bwa_path/$align_id.bam
  sorted_bam_file=$bwa_path/$align_id.sorted.bam
  bwa mem -t 20 -x intractg $reference $flanks_file 2>$bwa_path/bwa_mem.log.txt | samtools view -bS - > $bam_file
  samtools sort $bam_file 1>$sorted_bam_file
  samtools index $sorted_bam_file

  bed_path=$base_path/bed
  mkdir -p $bed_path
  bed_file=$bed_path/$align_id'_'flanks.bed
  merged_bed_file=$bed_path/$align_id'_'merged_flanks.bed
  bedtools bamtobed -i $sorted_bam_file > $bed_file
  bedtools merge -i $bed_file -d 100000 > $merged_bed_file

  gap_flank_file=$base_path/$align_id'_'gap_flank.fasta
  bedtools getfasta -fi $reference -bed $merged_bed_file > $gap_flank_file

done
