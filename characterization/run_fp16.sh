#!/usr/bin/env bash

cd fp16_dot_product
source env.sh

make syn
cp logs/results_32.log ../fp16_base.csv

cd ..
