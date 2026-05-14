#!/usr/bin/env bash

E=(2)
M=(1 3)

cd packed_multiplier

echo "Format,Fmax,ALMs,DSPs" | tee ../packed_base.csv
for e in ${E[@]}; do
	for m in ${M[@]}; do
#		make synth E=$e M=$m
		../extract_results.sh  packed_dot_product_fp32 . | tee -a ../packed_base.csv
		sed -i "s/packed_dot_product_fp32/E${e}_M${m}/" ../packed_base.csv
	done
done

E=(3)
M=(2)
for e in ${E[@]}; do
	for m in ${M[@]}; do
#		make synth E=$e M=$m
		../extract_results.sh  packed_dot_product_fp32 . | tee -a ../packed_base.csv
		sed -i "s/packed_dot_product_fp32/E${e}_M${m}/" ../packed_base.csv
	done
done

E=(4)
M=(3)
for e in ${E[@]}; do
	for m in ${M[@]}; do
#		make synth E=$e M=$m
		../extract_results.sh  packed_dot_product_fp32 . | tee -a ../packed_base.csv
		sed -i "s/packed_dot_product_fp32/E${e}_M${m}/" ../packed_base.csv
	done
done

E=(5)
M=(2)
for e in ${E[@]}; do
	for m in ${M[@]}; do
#		make synth E=$e M=$m
		../extract_results.sh  packed_dot_product_fp32 . | tee -a ../packed_base.csv
		sed -i "s/packed_dot_product_fp32/E${e}_M${m}/" ../packed_base.csv
	done
done

cd ..
