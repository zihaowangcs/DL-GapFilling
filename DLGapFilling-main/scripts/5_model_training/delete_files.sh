#!/bin/bash



if [ $# -lt 3 ]; then
  echo "delete target dir:  <target dir path> <to>(not include) <from>(include)"
  exit 1
fi

target_dir=$1;shift
end_dir=$1;shift
start_dir=$1;shift

cd $target_dir

flag=0

for dir in */;do
  gap_dir=$(echo $dir | sed 's/\///g')
  if [ "$gap_dir" = "$start_dir" ]; then
      flag=1
  fi
  if [ "$gap_dir" = "$end_dir" ]; then
      flag=0
  fi
  if [ $flag -eq 1 ]; then
      (rm -rf $gap_dir)
  fi
done

