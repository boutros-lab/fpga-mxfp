#!/bin/bash

input_stages=(1 2 3 4 5 6)
output_stages=(2 3 4 5 6)

out_dir="$PROJ_ROOT/sweep_logs"

rm -rf $PROJ_ROOT/logs

rm -rf $out_dir

mkdir $out_dir

for stages in "${input_stages[@]}"; do
	$PROJ_ROOT/scripts/run_all_types.sh $stages 1

	mkdir $out_dir/logs_${stages}_1

	mv $PROJ_ROOT/logs/* $out_dir/logs_${stages}_1
done

for stages in "${output_stages[@]}"; do
	$PROJ_ROOT/scripts/run_all_types.sh 1 $stages

	mkdir $out_dir/logs_1_${stages}

	mv $PROJ_ROOT/logs/* $out_dir/logs_1_${stages}
done

for stages in "${output_stages[@]}" ; do
	$PROJ_ROOT/scripts/run_all_types.sh $stages $stages

	mkdir $out_dir/logs_${stages}_${stages}

	mv $PROJ_ROOT/logs/* $out_dir/logs_${stages}_${stages}
done
