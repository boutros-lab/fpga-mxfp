#!/usr/bin/env bash

cd imperial_benchmark_exploration
source env.sh

E=(2 2 3 4 5)
M=(1 3 2 3 2)

for ((i=0; i<${#E[@]}; i++)); do

	make data_and_sim E=${E[$i]} M=${M[$i]} PIPE=0 > base_sim_E${E[$i]}_M${M[$i]}.log

	grep "PASSED" base_sim_E${E[$i]}_M${M[$i]}.log > /dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo Base E${E[$i]}_M${M[$i]} TEST PASSED
	else
		echo Base E${E[$i]}_M${M[$i]} TEST FAILED
	fi
done

cd ..
