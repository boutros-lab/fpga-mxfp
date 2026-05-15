#!/usr/bin/env bash

E=(2 2 3 4 5)
M=(1 3 2 3 2)

cd packed_multiplier

echo "Format,Fmax,ALMs,DSPs" | tee ../packed_base.csv
for ((i=0; i<${#E[@]}; i++)); do
	make synth E=${E[$i]} M=${M[$i]}
	../extract_results.sh packed_dot_product_fp32 . | tee -a ../packed_base.csv
	sed -i "s/packed_dot_product_fp32/E${E[$i]}_M${M[$i]}/" ../packed_base.csv
done

cd ..
