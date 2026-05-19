#!/usr/bin/env bash

E=(2)
M=(1)
N=(2 4 6 7 10 14 16 20)

mkdir -p results


for e in ${E[@]}; do
	for m in ${M[@]}; do
		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_aitb_prop_sweep.csv
		for n in ${N[@]}; do
			make fitaitb_prop E=$e M=$m N=$n IS_FP8_DOT4=0
			./extract.sh $n E${e}_M${m} aitb_prop
			tail -n 1 results/aitb_prop_E${e}_M${m}_N${n}.csv >> E${e}_M${m}_aitb_prop_sweep.csv
#		rm build_24_2 -rf
		done
	done
done

E=(2)
M=(3)
N=(2 4 6 7 10 14 16)

for e in ${E[@]}; do
	for m in ${M[@]}; do
		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_aitb_prop_sweep.csv
		for n in ${N[@]}; do
			make fitaitb_prop E=$e M=$m N=$n IS_FP8_DOT4=0
			./extract.sh $n E${e}_M${m} aitb_prop
			tail -n 1 results/aitb_prop_E${e}_M${m}_N${n}.csv >> E${e}_M${m}_aitb_prop_sweep.csv
#		rm build_24_2 -rf
		done
	done
done

E=(3)
M=(2)
N=(2 4 6 7 10 14 16)

for e in ${E[@]}; do
	for m in ${M[@]}; do
		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_aitb_prop_sweep.csv
		for n in ${N[@]}; do
			make fitaitb_prop E=$e M=$m N=$n IS_FP8_DOT4=0
			./extract.sh $n E${e}_M${m} aitb_prop
			tail -n 1 results/aitb_prop_E${e}_M${m}_N${n}.csv >> E${e}_M${m}_aitb_prop_sweep.csv
#		rm build_24_2 -rf
		done
	done
done

E=(4)
M=(3)
N=(2 4 6 7 10 14)

for e in ${E[@]}; do
	for m in ${M[@]}; do
		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_aitb_prop_sweep.csv
		for n in ${N[@]}; do
			make fitaitb_prop E=$e M=$m N=$n IS_FP8_DOT4=0
			./extract.sh $n E${e}_M${m} aitb_prop
			tail -n 1 results/aitb_prop_E${e}_M${m}_N${n}.csv >> E${e}_M${m}_aitb_prop_sweep.csv
#		rm build_24_2 -rf
		done
	done
done

E=(5)
M=(2)
N=(2 4 6 7 10 14)

for e in ${E[@]}; do
	for m in ${M[@]}; do
		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_aitb_prop_sweep.csv
		for n in ${N[@]}; do
			make fitaitb_prop E=$e M=$m N=$n IS_FP8_DOT4=0
			./extract.sh $n E${e}_M${m} aitb_prop
			tail -n 1 results/aitb_prop_E${e}_M${m}_N${n}.csv >> E${e}_M${m}_aitb_prop_sweep.csv
#		rm build_24_2 -rf
		done
	done
done
