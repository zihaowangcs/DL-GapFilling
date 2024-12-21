#!/bin/bash
if [ $# -lt 2 ]; then
	echo "Usage: $(basename $0) <fixed gap_id dir> <intersection_type: 1=intersection; 2=left_intersection; 3=right_intersection; 4=left_fixed; 5=right_fixed; 6=left_unfixed; 7=right_unfixed> <out dir>"
	exit 1
fi

fixed_dir=$1;shift
intersection_type=$1;shift
name="intersection"

cur_dir=$(pwd)

if [ $# -eq 1 ]; then
        cur_dir=$1;shift
fi

cd $fixed_dir

if [ "$intersection_type" == 1 ]; then
  name="intersection"
  elif [ "$intersection_type" == 2 ]; then
      name="left_intersection"
      elif [ "$intersection_type" == 3 ]; then
          name="right_intersection"
          elif [ "$intersection_type" == 4 ]; then
          name="left_fixed"
          elif [ "$intersection_type" == 5 ]; then
          name="right_fixed"
          elif [ "$intersection_type" == 6 ]; then
          name="left_unfixed"
          elif [ "$intersection_type" == 7 ]; then
          name="right_unfixed"
          else
            echo "intersection_type must between 1 and 7"
            exit 1
fi

if [ -f $cur_dir/$name.txt ]; then
    rm $cur_dir/$name.txt
fi

> $cur_dir/$name.txt

for gap_id in */;do
  echo $gap_id | cut -d'/' -f1 >> $cur_dir/$name.txt
done
