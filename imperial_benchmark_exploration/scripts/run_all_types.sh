#!/bin/bash

root="/home/msmekhem/lp_dsp/"

mul_int_default="$root/rtl/mul_int.sv"
mul_int_logic="$root/rtl/mul_int_logic.sv"
mul_int_dsp="$root/rtl/mul_int_dsp.sv"

input_stages=$1
output_stages=$2

rm -rf $root/logs/
mkdir $root/logs/

# Run k=8 and k=32 Default
$root/scripts/run_all_formats.sh -k 8  -i $input_stages -o $output_stages -m $mul_int_default -t default
$root/scripts/run_all_formats.sh -k 32 -i $input_stages -o $output_stages -m $mul_int_default -t default

# Run k=8 and k=32 LOGIC
$root/scripts/run_all_formats.sh -k 8  -i $input_stages -o $output_stages -m $mul_int_logic -t logic
$root/scripts/run_all_formats.sh -k 32 -i $input_stages -o $output_stages -m $mul_int_logic -t logic

# Run k=8 and k=32 DSP
$root/scripts/run_all_formats.sh -k 8  -i $input_stages -o $output_stages -m $mul_int_dsp -t dsp
$root/scripts/run_all_formats.sh -k 32 -i $input_stages -o $output_stages -m $mul_int_dsp -t dsp
