#!/bin/bash
if [ $# -lt 6 ]; then
	echo "Usage: $(basename $0) <1_abyss_assembly scaffold.fa> <5_sealer_gap_filling sealer_scaffold.fa> <origin data> <5_sealer_gap_filling sealer_merged.fa> <origin reference data> <suffix name>"
	exit 1
fi

out_dir=$(pwd)
scaffold_path=$1;shift
prediction_scaffold_path=$1;shift
origin_data=$1;shift

./extract_flanks_and_reads.sh ${scaffold_path} ${out_dir} ${origin_data}

gaps_file=${out_dir}/gene-scaffolds_gaps_flanks.fa
map_data=${out_dir}/gene_mappedSubset.fastq.gz

sealer_merged_path=$1;shift
suffix_name=$1;shift


./sample_random_gaps.sh ${gaps_file} ${sealer_merged_path} ${out_dir} 900 ${map_data} ${prediction_scaffold_path}


origin_reference_data=$1;shift
./gap_extract_pipeline.sh ${origin_reference_data}


prediction_path=${out_dir}/out
reference_path=${out_dir}/out



cd ${prediction_path}

type=fixed
cd ${prediction_path}/${type}

for directory in */; do
  gap_id=$(echo $directory | sed 's/\///g')

  prediction_fasta=${prediction_path}/${type}/${gap_id}/${gap_id}'_'gap_flank_prediction.fasta
  reference_fasta=${reference_path}/${type}/${gap_id}/${gap_id}'_'gap_flank_reference.fasta

  prediction_cut_fasta=${prediction_path}/${type}/${gap_id}/${gap_id}'_'gap_flank_prediction_cut.fasta
  reference_cut_fasta=${reference_path}/${type}/${gap_id}/${gap_id}'_'gap_flank_reference_cut.fasta

  > ${prediction_cut_fasta}
  > ${reference_cut_fasta}

  head -1 ${prediction_fasta} > ${prediction_cut_fasta}
  tail -1 ${prediction_fasta} | rev | cut -c 401- | rev | cut -c 401- >> ${prediction_cut_fasta}

  head -1 ${reference_fasta} > ${reference_cut_fasta}
  tail -1 ${reference_fasta} | rev | cut -c 401- | rev | cut -c 401- >> ${reference_cut_fasta}

  mkdir -p ${out_dir}/exonerate/${type}/${gap_id}
  exonerate ${prediction_cut_fasta} ${reference_cut_fasta} --ryo "percent_identity:%pi\nquery_start:%qab\nquery_length:%ql\nquery_alignment_length:%qal\nquery_end:%qae\ntarget_start:%tab\ntarget_end:%tae\ntarget_length:%tl\ntarget_alignment_length:%tal\ntotal_bases_compared:%et\nmismatches:%em\nmatches:%ei\ncigar:%C\n" --model affine:local --exhaustive y --bestn 1 > ${out_dir}/exonerate/${type}/${gap_id}/prediction_alignment.exn

done

rm ${out_dir}/gene-scaffolds*
rm ${out_dir}/gene_mappedSubset.fastq.gz
rm ${out_dir}/_summary.tsv

validation_dir=validation_$(date +%F_%R)_${suffix_name}
mkdir -p ${out_dir}/${validation_dir}
mv ${out_dir}/out ${out_dir}/${validation_dir}
mv ${out_dir}/exonerate ${out_dir}/${validation_dir}
