#!/usr/bin/env bash

cd packed_multiplier

E=(2 2 3 4 5)
M=(1 3 2 3 2)

for ((i=0; i<${#E[@]}; i++)); do
	make sim E=${E[$i]} M=${M[$i]} > packed_sim_E${E[$i]}_M${M[$i]}.log

	grep "PASSED" packed_sim_E${E[$i]}_M${M[$i]}.log > /dev/null 2>&1

	if [ $? -eq 0 ]; then
		echo Packed E${E[$i]}_M${M[$i]} TEST PASSED
	else
		echo Packed E${E[$i]}_M${M[$i]} TEST FAILED
	fi
done

cd ..
