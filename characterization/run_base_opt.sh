#!/usr/bin/env bash

cd imperial_benchmark_exploration
source env.sh

sed -i 's/ALLOW_REGISTER_RETIMING OFF/ALLOW_REGISTER_RETIMING ON/' quartus_tcl/dot_setup_fp32.tcl
./scripts/run_all_formats.sh 1

cp logs/results_32.log ../base_opt.csv

cd ..
