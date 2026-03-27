# initialize variables
TOP_LEVEL_NAME="mxfp_dot_proposed_tb"

QUARTUS_INSTALL_DIR=$QUARTUS_ROOT
SKIP_SIM=1
USER_DEFINED_ELAB_OPTIONS="+vcs+lic+wait -debug_access+pp"
#USER_DEFINED_ELAB_OPTIONS="+vcs+lic+wait"
USER_DEFINED_ELAB_OPTIONS_APPEND=""
USER_DEFINED_SIM_OPTIONS=""

# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

#-------------------------------------------
# check tclsh version no earlier than 8.5 
version=$(echo "puts [package vcompare [info tclversion] 8.5]; exit" | tclsh)
if [ $version -eq -1 ]; then 
  echo "Error: Minimum required tcl package version is 8.5." >&2 
  exit 1 
fi 

ELAB_OPTIONS=""

# -------------------------------------------
# design files
design_files=(
"../../aitb_asic/rtl/pkg_aitb.sv"
"mxfp_dot_proposed_tb.sv"
"../rtl/mxfp_dot_proposed.sv"
"../rtl/mxfp_dot_prop_mxfp4.sv"
"../rtl/fp_aitb_proposed.sv"
"../../aitb_asic/rtl/mxfp_aitb/naive_mxfp_aitb_top.sv"
"../../aitb_asic/rtl/mxfp_aitb/config_gen.sv"
"../../aitb_asic/rtl/in_reg_bank.sv"
"../../aitb_asic/rtl/pipeline.sv"
"../../aitb_asic/rtl/mxfp_aitb/input_preparation_mxfp.sv"
"../../aitb_asic/rtl/mxfp_dot/naive_mxfp_dot_fixed.sv"
"../../aitb_asic/rtl/mxfp_dot/config_fix2fp32.sv"
"../../aitb_asic/rtl/ieee_fp32_add.vhdl"
"../../aitb_asic/rtl/mxfp_dot/mxfp_mult_shift.sv"
"../../aitb_asic/rtl/mxfp_dot/naive_reduction.sv"
"../../aitb_asic/rtl/mxfp_dot/flopoco_normalizers/normalizer_sgn_70b.vhdl"
"../../aitb_asic/rtl/mxfp_dot/mxfp_multiply.sv"
"../../aitb_asic/rtl/mxfp_dot/flopoco_shifters/fp8_67_shifter.vhdl"
"../../aitb_asic/rtl/mxfp_dot/pow2_reduction_norecurse.sv"
)

# -------------------------------------------
# split files by language
sv_files=()
v_files=()
vhdl_files=()

for f in "${design_files[@]}"; do
  case "$f" in
    *.sv)
      sv_files+=("$f")
      ;;
    *.v)
      v_files+=("$f")
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
# clean old compile database if desired
# rm -rf csrc simv simv.daidir ucli.key work.vhdlan
# rm -rf .vlogan .vhdlan

# -------------------------------------------
# compile Verilog/SystemVerilog libraries and sources
if [ ${#v_files[@]} -gt 0 ] || [ ${#sv_files[@]} -gt 0 ]; then
  vlogan -full64 -l vlogan.log \
    -assert svaext \
    -timescale=1ps/1ps \
    -sverilog \
    +v2k \
    +verilog2001ext+.v \
    -work work \
    "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv" \
    "$QUARTUS_INSTALL_DIR/eda/sim_lib/tennm_atoms.sv" \
    "$QUARTUS_INSTALL_DIR/eda/sim_lib/synopsys/tennm_atoms_ncrypt.sv" \
    -v "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v" \
    -v "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v" \
    -v "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v" \
    -v "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v" \
    "${v_files[@]}" \
    "${sv_files[@]}"

  if [ $? -ne 0 ]; then
    echo "Error: vlogan compilation failed." >&2
    exit 1
  fi
fi

# -------------------------------------------
# compile VHDL sources
if [ ${#vhdl_files[@]} -gt 0 ]; then
  vhdlan -full64 -l vhdlan.log \
    -work work \
    "${vhdl_files[@]}"

  if [ $? -ne 0 ]; then
    echo "Error: vhdlan compilation failed." >&2
    exit 1
  fi
fi

# -------------------------------------------
# elaborate
vcs -full64 -lca \
  -assert svaext \
  -l elaborate.log \
  -debug_access+pp \
  -LDFLAGS -no-pie \
  $USER_DEFINED_ELAB_OPTIONS \
  $USER_DEFINED_ELAB_OPTIONS_APPEND \
  -top "$TOP_LEVEL_NAME"

if [ $? -ne 0 ]; then
  echo "Error: vcs elaboration failed." >&2
  exit 1
fi

#-top $TOP_LEVEL_NAME -R
#-top $TOP_LEVEL_NAME -R -gui &

# simulate
# if [ $SKIP_SIM -eq 0 ]; then
#   ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
# fi

# ./simv -top npu_tb -R #-gui &