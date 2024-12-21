#!/bin/bash
if [ $# -lt 1 ]; then
	echo "Usage: $(basename $0) <output_dir output path> <gap_id_path file> <sealer_flanks_and_gaps set 1 path>"
	exit 1
fi

output_dir=$1;shift
txt_path=$1;shift
predictions_path=$1;shift

cur_dir=$(pwd)
$cur_dir/intersection_create.sh $predictions_path/fixed 4 ${output_dir}
$cur_dir/intersection_create.sh $predictions_path/fixed 5 ${output_dir}
$cur_dir/intersection_create.sh $predictions_path/unfixed 6 ${output_dir}
$cur_dir/intersection_create.sh $predictions_path/unfixed 7 ${output_dir}

mkdir -p $output_dir

> $output_dir/set1_gappredict_forward.fasta
> $output_dir/set1_gappredict_rc.fasta
> $output_dir/set1_gappredict.fasta
> $output_dir/set2_gappredict_forward.fasta
> $output_dir/set2_gappredict_rc.fasta
> $output_dir/set2_gappredict.fasta

while read gap_id; do
    cat $predictions_path/fixed/${gap_id}/beam_search/predict_gap/forward/beam_search_predictions.fasta >> $output_dir/set1_gappredict_forward.fasta
    echo >> $output_dir/set1_gappredict_forward.fasta
done < $txt_path/left_fixed.txt

while read gap_id; do
    cat $predictions_path/fixed/${gap_id}/beam_search/predict_gap/reverse_complement/beam_search_predictions.fasta >> $output_dir/set1_gappredict_rc.fasta
    echo >> $output_dir/set1_gappredict_rc.fasta
done < $txt_path/right_fixed.txt

while read gap_id; do
    cat $predictions_path/unfixed/${gap_id}/beam_search/predict_gap/forward/beam_search_predictions.fasta >> $output_dir/set2_gappredict_forward.fasta
    echo >> $output_dir/set2_gappredict_forward.fasta
done < $txt_path/left_unfixed.txt

while read gap_id; do
    cat $predictions_path/unfixed/${gap_id}/beam_search/predict_gap/reverse_complement/beam_search_predictions.fasta >> $output_dir/set2_gappredict_rc.fasta
    echo >> $output_dir/set2_gappredict_rc.fasta
done < $txt_path/right_unfixed.txt

cat $output_dir/set1_gappredict_forward.fasta $output_dir/set1_gappredict_rc.fasta > $output_dir/set1_gappredict.fasta
cat $output_dir/set2_gappredict_forward.fasta $output_dir/set2_gappredict_rc.fasta > $output_dir/set2_gappredict.fasta