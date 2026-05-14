#!/usr/bin/env bash

cd imperial_benchmark_exploration
source env.sh

./scripts/run_all_formats.sh 1

cp logs/results_32.log ../base_opt.csv

cd ..
