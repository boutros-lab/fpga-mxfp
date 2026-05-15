#!/usr/bin/env bash

cd fp16_dot_product
source env.sh

E=(2 2 3 4 5)
M=(1 3 2 3 2)

for ((i=0; i<${#E[@]}; i++)); do
	if [ ${E[$i]} -eq 5 ]; then
		make data_and_sim E=${E[$i]} M=${M[$i]} DATA_OPTS=--no_infnan > fp16_sim_E${E[$i]}_M${M[$i]}.log
	else 
		make data_and_sim E=${E[$i]} M=${M[$i]} > fp16_sim_E${E[$i]}_M${M[$i]}.log
	fi

	grep "PASSED" fp16_sim_E${E[$i]}_M${M[$i]}.log > /dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo E${E[$i]}_M${M[$i]} TEST PASSED
	else
		echo E${E[$i]}_M${M[$i]} TEST FAILED
	fi
done

cd ..
