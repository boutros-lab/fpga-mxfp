#!/bin/bash

TOP_LEVEL_NAME="sys_array_aitb_tb"
USER_DEFINED_SIM_OPTIONS=""

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# -------------------------------------------
# clean old compile database
rm -rf work

# -------------------------------------------
# design files
design_files=(
"sys_array_aitb_tb.sv"
"../rtl/sys_array_aitb.sv"
"../../characterization/ai_tensor_block/rtl/mxfp_dot.sv"
"../../characterization/ai_tensor_block/rtl/fp_aitb.sv"
"../../characterization/ai_tensor_block/rtl/pipeline.sv"
)

# -------------------------------------------
# create work library
vlib work

# -------------------------------------------
# compile SystemVerilog sources
vlog -sv "${design_files[@]}"
if [ $? -ne 0 ]; then
  echo "Error: vlog compilation failed." >&2
  exit 1
fi

# -------------------------------------------
# simulate
vsim -c work.$TOP_LEVEL_NAME -L tennm_ver -voptargs="+acc" \
  $USER_DEFINED_SIM_OPTIONS \
  -do "run -all; quit"
