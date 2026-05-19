#!/usr/bin/env bash

E=(2)
M=(1 3)
N=(2 4 6 7 10 14)

mkdir -p results


for e in ${E[@]}; do
	for m in ${M[@]}; do
		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_aitb_sweep.csv
		for n in ${N[@]}; do
			make fitaitb E=$e M=$m N=$n
			./extract.sh $n E${e}_M${m}_N${n} aitb
			tail -n 1 results/aitb_E${e}_M${m}_N${n}.csv >> E${e}_M${m}_aitb_sweep.csv
#		rm build_24_2 -rf
		done
	done
done
