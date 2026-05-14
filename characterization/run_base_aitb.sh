#!/usr/bin/env bash

E=(2)
M=(1 3)

cd ai_tensor_block

echo "Format,Fmax,ALMs,DSPs" | tee ../aitb_base.csv
for e in ${E[@]}; do
	for m in ${M[@]}; do
#		make fit E=$e M=$m
		../extract_results.sh E${e}_M${m} syn/output_files_E${e}_M${m} | tee -a ../aitb_base.csv
	done
done

cd ..
