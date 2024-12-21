#!/bin/bash

if [ $# -ne 4 ]; then
	echo "Usage: $(basename $0) <predicted dir> <read directory> <Draft scaffolds FASTA> <mark>"
	exit 1
fi

cur_dir=$(pwd)

predicted_dir=$1;shift
data_dir=$1;shift
draft_scaffolds_dir=$1;shift
mark=$1;shift

new_dir=gapfillpredict_$(date +%F_%R)_${mark}

mkdir $new_dir

out_dir=${cur_dir}/${new_dir}

${cur_dir}/pool_gappredict_pass.sh ${out_dir} ${out_dir} ${predicted_dir}

${cur_dir}/runme_ABySS-bloom.sh ${data_dir} ${out_dir} ${out_dir} &


sleep 1

while pgrep -f abyss-bloom.slurm > /dev/null; do
    sleep 1
done

${cur_dir}/run-sealerAllReads.sh ${draft_scaffolds_dir} ${out_dir}

(mv gene-scaffolds* ${out_dir})

(mv -r log ${out_dir})

python ./sort_evaluate_file.py .
