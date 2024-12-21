#!/bin/bash


if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file1> <input_file2> <output_file>"
    exit 1
fi


FILE1=$1
FILE2=$2
OUTPUT=$3


python3 - <<END
import pandas as pd


file1_path = '$FILE1'
file2_path = '$FILE2'

df1 = pd.read_csv(file1_path)
df2 = pd.read_csv(file2_path)


merged_df = pd.merge(df1, df2, on='gap_id', suffixes=('_sealer', '_ddlgap'))


filtered_df = merged_df[merged_df['percent_identity_sealer'] < merged_df['percent_identity_ddlgap']]

if filtered_df.empty:
    result_df = pd.DataFrame(columns=['gap_id', 'is_fixed', 'percent_identity', 'query_start', 'query_end', 'query_length', 
                                      'query_alignment_length', 'target_start', 'target_end', 'target_length', 
                                      'target_alignment_length', 'total_bases_compared', 'mismatches', 'matches', 'total_length'])
else:
    
    result_df = filtered_df[['gap_id', 'is_fixed_sealer', 'percent_identity_sealer', 'query_start_sealer', 
                             'query_end_sealer', 'query_length_sealer', 'query_alignment_length_sealer', 
                             'target_start_sealer', 'target_end_sealer', 'target_length_sealer', 
                             'target_alignment_length_sealer', 'total_bases_compared_sealer', 'mismatches_sealer', 
                             'matches_sealer', 'total_length_sealer']]

    result_df.columns = ['gap_id', 'is_fixed', 'percent_identity', 'query_start', 'query_end', 'query_length', 
                         'query_alignment_length', 'target_start', 'target_end', 'target_length', 
                         'target_alignment_length', 'total_bases_compared', 'mismatches', 'matches', 'total_length']


output_path = '$OUTPUT'
result_df.to_csv(output_path, index=False)


