#!/bin/bash

if [ $# -lt 4 ]; then
  echo "Usage: $(basename $0) <DGCNet lib directory> <fixed> <unfixed> <out dir> <fixed start id>  <unfixed start id>"
	exit 1
fi

lib_dir=$1; shift
fixed=$1; shift
unfixed=$1; shift
outdir=$1; shift
fixedstartid=$1;shift
unfixedstartid=$1;shift

if [ $# -gt 0 ]; then
  batch_size=$1;shift
  embedding_dim=$1;shift
  latent_dim=$1;shift
  cnn_filter=$1;shift
fi

now_path=$(pwd)

cd $fixed

flag=0

for directory in */;do
  fix_file=$(echo $directory | sed 's/\///g')
  if [ "$fixedstartid" = "$fix_file" ]; then
      flag=1
  fi
  if [ "$fixedstartid" = "skip" ]; then
      flag=1
  fi
  if [ $flag -eq 1 ]; then
      fixed_dir_path=$fixed/$fix_file
      cd $fixed_dir_path
      if [ $(ls -l | grep "^-" | wc -l) -lt 2 ]; then
          echo "$fixed_dir_path low than 2 files"
          exit 1
      fi
      if [ -z "$batch_size" ]; then
        $now_path/train_gap.sh $lib_dir $fixed_dir_path/$fix_file.fasta $fixed_dir_path/$fix_file.fastq $outdir/out/fixed
      else
        $now_path/train_gap.sh $lib_dir $fixed_dir_path/$fix_file.fasta $fixed_dir_path/$fix_file.fastq $outdir/out/fixed ${batch_size} ${embedding_dim} ${latent_dim} ${cnn_filter}
      fi
      wait
  fi
done

flag=0

cd $unfixed

for directory in */;do
  fix_file=$(echo $directory | sed 's/\///g')
  if [ "$unfixedstartid" = "$fix_file" ]; then
      flag=1
  fi
  if [ "$unfixedstartid" = "skip" ]; then
      flag=1
  fi
  if [ $flag -eq 1 ]; then
      fixed_dir_path=$unfixed/$fix_file
      cd $fixed_dir_path
      if [ $(ls -l | grep "^-" | wc -l) -lt 2 ]; then
          echo "$fixed_dir_path low than 2 files"
          exit 1
      fi
      if [ -z "$batch_size" ]; then
        $now_path/train_gap.sh $lib_dir $fixed_dir_path/$fix_file.fasta $fixed_dir_path/$fix_file.fastq $outdir/out/unfixed
      else
        $now_path/train_gap.sh $lib_dir $fixed_dir_path/$fix_file.fasta $fixed_dir_path/$fix_file.fastq $outdir/out/unfixed ${batch_size} ${embedding_dim} ${latent_dim} ${cnn_filter}
      fi
      wait
  fi
done




