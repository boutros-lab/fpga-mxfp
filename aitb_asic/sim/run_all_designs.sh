#!/bin/bash

description=("(1) Fixed-point inputs"
	     "(2) MXFP inputs (all)"
             "(3.1) MXFP inputs (No MXFP8)"
             "(3.2) MXFP inputs (No E5M2)"
             "(3.3) MXFP inputs (reduce E5M2)"
             "(4) MXFP inputs (No E5M2)")

designs=("fixed_input_mxfp_aitb_wrapper" 
	 "naive_mxfp_aitb_comp_wrapper" 
	 "nofp8_mxfp_aitb_comp_wrapper" 
	 "noe5m2_mxfp_aitb_comp_wrapper" 
	 "e5m2_4_mxfp_aitb_comp_wrapper" 
	 "noe5m2_fixed8_mxfp_aitb_comp_wrapper")

k=("10 16 11 8" 
   "10 16 12 12 8 8" 
   "10 16 12 12" 
   "10 16 12 12 8" 
   "10 16 12 12 8 4" 
   "8 16 12 12 8")

exp=("0 2 2 3" 
     "0 2 2 3 4 5"
     "0 2 2 3"
     "0 2 2 3 4"
     "0 2 2 3 4 5"
     "0 2 2 3 4")

man=("7 1 3 2" 
     "7 1 3 2 3 2"
     "7 1 3 2"
     "7 1 3 2 3"
     "7 1 3 2 3 2"
     "7 1 3 2 3")

cd $PROJ_ROOT

echo "Simulation results for all designs:" > all_designs.log
echo "PLACEHOLDER" >> all_designs.log
echo "" >> all_designs.log

for ((i=0; i<${#k[@]}; i++)); do
	echo "" | tee -a all_designs.log
	echo "${description[i]}" | tee -a all_designs.log
	echo "" | tee -a all_designs.log

	if [ $i -eq 0 ]; then
		# Design 1 needs fixed point inputs
		./sim/run_all_formats.sh -d ${designs[i]} -k "${k[i]}" -e "${exp[i]}" -m "${man[i]}" -f | tee -a all_designs.log
	else
		./sim/run_all_formats.sh -d ${designs[i]} -k "${k[i]}" -e "${exp[i]}" -m "${man[i]}" | tee -a all_designs.log
	fi
done

failures=`grep "FAILED" all_designs.log | wc -l`

if [ $failures -eq 0 ]; then
	sed -i "s/PLACEHOLDER/ALL PASSED!/g" all_designs.log
	echo "All tests passed, detailed results placed in all_designs.log"
else
	sed -i "s/PLACEHOLDER/FAILURES DETECTED!/g" all_designs.log
	echo "Failures detected, detailed results placed in all_designs.log"
fi

echo "Individual tests can be viewed in test_logs/"
