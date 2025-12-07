#!/bin/bash

root="/home/msmekhem/lp_dsp/"

input_stages=(1 2 3 4 5 6)
output_stages=(2 3 4 5 6)

out_dir="$root/sweep_logs"

rm -rf $root/logs

#rm -rf $out_dir
#
#mkdir $out_dir
#
#for stages in "${input_stages[@]}"; do
#	$root/scripts/run_all_types.sh $stages 1
#
#	mkdir $out_dir/logs_${stages}_1
#
#	mv $root/logs/* $out_dir/logs_${stages}_1
#done
#
#for stages in "${output_stages[@]}"; do
#	$root/scripts/run_all_types.sh 1 $stages
#
#	mkdir $out_dir/logs_1_${stages}
#
#	mv $root/logs/* $out_dir/logs_1_${stages}
#done

for stages in "${output_stages[@]}" ; do
	$root/scripts/run_all_types.sh $stages $stages

	mkdir $out_dir/logs_${stages}_${stages}

	mv $root/logs/* $out_dir/logs_${stages}_${stages}
done
