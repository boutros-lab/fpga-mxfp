#!/usr/bin/env bash

E=(2)
M=(1 3)

mkdir -p results

echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_mxfp_dot_prop_sweep.csv

for e in ${E[@]}; do
	for m in ${M[@]}; do
#		make fitmxfp_dot_prop E=$e M=$m N=$n
		./extract.sh E${e}_M${m} E${e}_M${m} mxfp_dot_prop
		tail -n 1 results/mxfp_dot_prop_E${e}_M${m}.csv >> mxfp_dot_prop_sweep.csv
	done
done

E=(3)
M=(2)

for e in ${E[@]}; do
	for m in ${M[@]}; do
#		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_mxfp_dot_prop_sweep.csv
#		make fitmxfp_dot_prop E=$e M=$m N=$n
		./extract.sh E${e}_M${m} E${e}_M${m} mxfp_dot_prop
		tail -n 1 results/mxfp_dot_prop_E${e}_M${m}.csv >> mxfp_dot_prop_sweep.csv
	done
done

E=(4)
M=(3)

for e in ${E[@]}; do
	for m in ${M[@]}; do
#		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_mxfp_dot_prop_sweep.csv
#		make fitmxfp_dot_prop E=$e M=$m N=$n
		./extract.sh E${e}_M${m} E${e}_M${m} mxfp_dot_prop
		tail -n 1 results/mxfp_dot_prop_E${e}_M${m}.csv >> mxfp_dot_prop_sweep.csv
	done
done

E=(5)
M=(2)

for e in ${E[@]}; do
	for m in ${M[@]}; do
#		echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > E${e}_M${m}_mxfp_dot_prop_sweep.csv
#		make fitmxfp_dot_prop E=$e M=$m N=$n
		./extract.sh E${e}_M${m} E${e}_M${m} mxfp_dot_prop
		tail -n 1 results/mxfp_dot_prop_E${e}_M${m}.csv >> mxfp_dot_prop_sweep.csv
	done
done
