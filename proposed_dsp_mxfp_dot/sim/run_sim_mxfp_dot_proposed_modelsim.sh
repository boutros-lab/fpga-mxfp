#!/bin/bash

TOP_LEVEL_NAME="mxfp_dot_proposed_tb"
QUARTUS_INSTALL_DIR=$QUARTUS_ROOT
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
"../../aitb_asic/rtl/pkg_aitb.sv"
"mxfp_dot_proposed_tb.sv"
"../rtl/mxfp_dot_proposed.sv"
"../rtl/mxfp_dot_prop_mxfp4.sv"
"../rtl/mxfp_dot_prop_mxfp6.sv"
"../rtl/mxfp_dot_prop_mxfp8.sv"
"../rtl/mxfp_dot_prop_mxfp8_dot4aitb.sv"
"../rtl/fp_aitb_proposed.sv"
"../../aitb_asic/rtl/mxfp_aitb/naive_mxfp_aitb_comp_top.sv"
"../../aitb_asic/rtl/mxfp_aitb/config_gen.sv"
"../../aitb_asic/rtl/in_reg_bank.sv"
"../../aitb_asic/rtl/pipeline.sv"
"../../aitb_asic/rtl/mxfp_dot/input_preparation_mxfp_comp.sv"
"../../aitb_asic/rtl/mxfp_dot/naive_mxfp_comp_dot_fixed.sv"
"../../aitb_asic/rtl/mxfp_dot/config_fix2fp32.sv"
"../../aitb_asic/rtl/ieee_fp32_add.vhdl"
"../../aitb_asic/rtl/mxfp_dot/mxfp_mult_comp_shift.sv"
"../../aitb_asic/rtl/mxfp_dot/flopoco_shifters/fp8_67_shifter.vhdl"
"../../aitb_asic/rtl/mxfp_dot/mxfp_multiply_comp.sv"
"../../aitb_asic/rtl/mxfp_dot/flopoco_normalizers/normalizer_sgn_70b.vhdl"
"../../aitb_asic/rtl/mxfp_dot/naive_reduction.sv"
"../../aitb_asic/rtl/mxfp_dot/pow2_reduction_norecurse.sv"
)

# -------------------------------------------
# split files by language
sv_files=()
vhdl_files=()

for f in "${design_files[@]}"; do
  case "$f" in
    *.sv)
      sv_files+=("$f")
      ;;
    *.vhd|*.vhdl)
      vhdl_files+=("$f")
      ;;
    *)
      echo "Warning: Unknown file extension, skipping: $f"
      ;;
  esac
done

# -------------------------------------------
# create work library
vlib work

# -------------------------------------------
# compile SystemVerilog sources
if [ ${#sv_files[@]} -gt 0 ]; then
  vlog -sv "${sv_files[@]}"
  if [ $? -ne 0 ]; then
    echo "Error: vlog compilation failed." >&2
    exit 1
  fi
fi

# -------------------------------------------
# compile VHDL sources (preserving order from design_files)
if [ ${#vhdl_files[@]} -gt 0 ]; then
  for f in "${vhdl_files[@]}"; do
    vcom "$f"
    if [ $? -ne 0 ]; then
      echo "Error: vcom compilation failed on $f." >&2
      exit 1
    fi
  done
fi

# -------------------------------------------
# simulate
vsim -c work.$TOP_LEVEL_NAME -L tennm_ver -voptargs="+acc" \
  $USER_DEFINED_SIM_OPTIONS \
  -do "run -all; quit"
