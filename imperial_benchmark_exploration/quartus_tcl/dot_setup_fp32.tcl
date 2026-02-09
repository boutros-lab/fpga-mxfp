# 0: Project Directory
# 1: Project Name
# 2: Project Revision
# 3: Exponent Width
# 4: Mantissa Width
# 5: K
# 6: Input Register Stages
# 7: Dot FP Register Stages
# 8: Output Register Stages
# 9: mult_int.sv, in order to use versions with different synthesis directives

package require ::quartus::project

set PROJ_DIR_NAME   [lindex $argv 0]
file mkdir $PROJ_DIR_NAME

set ROOT [pwd]
set MXROOT [file join $ROOT $ROOT/MX-for-FPGA/src/]

cd $PROJ_DIR_NAME

set PROJ          [lindex $argv 1]
set REV           [lindex $argv 2]
set FAMILY        "Agilex 5"
set DEVICE        "A5EC065BB32AE4S"
set SDC_FILE      [file join $ROOT $ROOT/quartus_tcl/mx_dp.sdc]
set EXP_WIDTH     [lindex $argv 3]
set MAN_WIDTH     [lindex $argv 4]
set K             [lindex $argv 5]
set INPUT_STAGES  [lindex $argv 6]
set DOT_FP_STAGES [lindex $argv 7]
set PIPELINE_ADD  [lindex $argv 8]
set FP32_STAGES   [lindex $argv 9]
set OUTPUT_STAGES [lindex $argv 10]
set MULT_INT      [lindex $argv 11]

set PIPELINE_FLOPOCO [lindex $argv 12]


if {[project_exists $PROJ]} {
		project_open -revision $REV $PROJ
} else {
		project_new -revision $REV $PROJ
}

# Set Family and Device
set_global_assignment -name FAMILY $FAMILY
set_global_assignment -name DEVICE $DEVICE

# Set Quartus Version
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 25.3.0
set_global_assignment -name LAST_QUARTUS_VERSION "25.3.0 Pro Edition"

# Add flopoco circuit
if { $PIPELINE_FLOPOCO == 1 } {
	set_global_assignment -name VHDL_FILE [file normalize $ROOT/fx2fp_flopoco/pipelined/mxfp_e${EXP_WIDTH}m${MAN_WIDTH}_to_fp32.vhdl]
} else {
	set_global_assignment -name VHDL_FILE [file normalize $ROOT/fx2fp_flopoco/combinational/mxfp_e${EXP_WIDTH}m${MAN_WIDTH}_to_fp32.vhdl]
}

# Get Verilog files and SDC file
# mul_int will be changed based on current run (dsp, logic, etc.)
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $MXROOT/util/arith/vec_mul_fp.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/vec_sum_int.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $MXROOT/util/arith/mul_fp.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $MULT_INT]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/dot_fp.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/dot_fp_fp32.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/pipeline.sv]
set_global_assignment -name SDC_FILE [file normalize $SDC_FILE]

# Set number of processors and top design
set_global_assignment -name TOP_LEVEL_ENTITY dot_fp_fp32
set_global_assignment -name NUM_PARALLEL_PROCESSORS 24
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "output_files"

# Set virtual pins
set_instance_assignment -name VIRTUAL_PIN ON -to rst -entity dot_fp_fp32
set_instance_assignment -name VIRTUAL_PIN ON -to i_vec_a -entity dot_fp_fp32
set_instance_assignment -name VIRTUAL_PIN ON -to i_vec_b -entity dot_fp_fp32
set_instance_assignment -name VIRTUAL_PIN ON -to o_fp32_q -entity dot_fp_fp32

# Set parameters
set_parameter -name exp_width     $EXP_WIDTH
set_parameter -name man_width     $MAN_WIDTH
set_parameter -name k             $K
set_parameter -name input_stages  $INPUT_STAGES
set_parameter -name dot_fp_stages $DOT_FP_STAGES
set_parameter -name pipeline_add  $PIPELINE_ADD
set_parameter -name fp32_stages   $FP32_STAGES
set_parameter -name output_stages $OUTPUT_STAGES

# Disable retiming
set_global_assignment -name ALLOW_REGISTER_RETIMING OFF

# Other Assignments
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
set_instance_assignment -name PARTITION_COLOUR 4285333442 -to dot_fp_staged -entity dot_fp_staged

# Commit assignments
export_assignments

project_close

