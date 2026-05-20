#!/usr/bin/env bash

cd ai_tensor_block

E=(2 2)
M=(1 3)

for ((i=0; i<${#E[@]}; i++)); do
	make sim E=${E[$i]} M=${M[$i]} > aitb_sim_E${E[$i]}_M${M[$i]}.log

	grep "PASSED" aitb_sim_E${E[$i]}_M${M[$i]}.log > /dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo AITB E${E[$i]}_M${M[$i]} TEST PASSED
	else
		echo AITB E${E[$i]}_M${M[$i]} TEST FAILED
	fi
done

cd ..
