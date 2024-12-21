#!/bin/bash

root_path=$(pwd)/out

type=fixed

cd ${root_path}/${type}/${type}

mv ${root_path}/${type}/${type}/* ${root_path}/${type}/

rm -rf ${root_path}/${type}/${type}

cd ${root_path}/${type}

mkdir -p ${root_path}/${type}_tmp

for directory in */; do
  gap_id=$(echo $directory | sed 's/\///g')
  mv ${root_path}/${type}/${gap_id}/* ${root_path}/${type}_tmp/
  #echo "${root_path}/${type}/${gap_id}/    ${root_path}/${type}_tmp/"
done

rm -rf ${root_path}/${type}

mv ${root_path}/${type}_tmp ${root_path}/${type}


type=unfixed

cd ${root_path}/${type}/${type}

mv ./* ../

cd ..

rm -rf ${type}

mkdir -p ${root_path}/${type}_tmp

for directory in */; do
  gap_id=$(echo $directory | sed 's/\///g')
  mv ${root_path}/${type}/${gap_id}/* ${root_path}/${type}_tmp/
done

rm -rf ${root_path}/${type}

mv ${root_path}/${type}_tmp ${root_path}/${type}
