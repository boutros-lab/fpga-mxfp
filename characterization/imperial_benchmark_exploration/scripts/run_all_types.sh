#!/bin/bash

PROJ_ROOT="/home/msmekhem/lp_dsp/"

mul_int_default="$RTL_ROOT/mul_int.sv"
mul_int_logic="$RTL_ROOT/mul_int_logic.sv"
mul_int_dsp="$RTL_ROOT/mul_int_dsp.sv"

input_stages=$1
output_stages=$2

rm -rf $PROJ_ROOT/logs/
mkdir $PROJ_ROOT/logs/

# Run k=8 and k=32 Default
$PROJ_ROOT/scripts/run_all_formats.sh -k 8  -i $input_stages -o $output_stages -m $mul_int_default -t default
$PROJ_ROOT/scripts/run_all_formats.sh -k 32 -i $input_stages -o $output_stages -m $mul_int_default -t default

# Run k=8 and k=32 LOGIC
$PROJ_ROOT/scripts/run_all_formats.sh -k 8  -i $input_stages -o $output_stages -m $mul_int_logic -t logic
$PROJ_ROOT/scripts/run_all_formats.sh -k 32 -i $input_stages -o $output_stages -m $mul_int_logic -t logic

# Run k=8 and k=32 DSP
$PROJ_ROOT/scripts/run_all_formats.sh -k 8  -i $input_stages -o $output_stages -m $mul_int_dsp -t dsp
$PROJ_ROOT/scripts/run_all_formats.sh -k 32 -i $input_stages -o $output_stages -m $mul_int_dsp -t dsp
