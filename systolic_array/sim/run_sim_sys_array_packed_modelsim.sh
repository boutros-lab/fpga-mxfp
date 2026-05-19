#!/bin/bash

TOP_LEVEL_NAME="sys_array_packed_mult_tb"
USER_DEFINED_SIM_OPTIONS=""

# Default MXFP format (e4m3); overridden by sweep script via EXP_W / MAN_W args
EXP_W=4
MAN_W=3

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# Select the mxfp_eXmY_to_fp32.vhdl that matches EXP_W / MAN_W
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VHDL_DIR="$SCRIPT_DIR/../../characterization/packed_multiplier/flopoco_fx2fp_pipelined"
MXFP_VHDL_FILE="${VHDL_DIR}/mxfp_e${EXP_W}m${MAN_W}_to_fp32.vhdl"
if [ ! -f "$MXFP_VHDL_FILE" ]; then
  echo "Error: VHDL file not found for EXP_W=${EXP_W} MAN_W=${MAN_W}: $MXFP_VHDL_FILE" >&2
  exit 1
fi

# -------------------------------------------
# clean old compile database
rm -rf work

# -------------------------------------------
# design files
sv_files=(
"sys_array_packed_mult_tb.sv"
"../rtl/sys_array_packed_mult.sv"
"../../characterization/packed_multiplier/packed_dot_product_fp32.sv"
"../../characterization/packed_multiplier/packed_dot_product.sv"
"../../characterization/packed_multiplier/packed_multiplier.sv"
"../../characterization/packed_multiplier/DSP_2x18x18.sv"
"../../characterization/packed_multiplier/reduction.sv"
"../../characterization/ai_tensor_block/rtl/pipeline.sv"
)

# -------------------------------------------
# create work library
vlib work

# -------------------------------------------
# compile SystemVerilog sources
vlog -sv "${sv_files[@]}"
if [ $? -ne 0 ]; then
  echo "Error: vlog compilation failed." >&2
  exit 1
fi

# -------------------------------------------
# compile VHDL source
vcom "$MXFP_VHDL_FILE"
if [ $? -ne 0 ]; then
  echo "Error: vcom compilation failed on $MXFP_VHDL_FILE." >&2
  exit 1
fi

# -------------------------------------------
# simulate
vsim -c work.$TOP_LEVEL_NAME -L tennm_ver -voptargs="+acc" \
  $USER_DEFINED_SIM_OPTIONS \
  -do "run -all; quit"
