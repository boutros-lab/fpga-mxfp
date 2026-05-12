package require ::quartus::project

set PROJ_DIR_NAME "syn" 
file mkdir $PROJ_DIR_NAME

set ROOT [pwd]
#set MXROOT [file join $ROOT $ROOT/MX-for-FPGA/src/]

cd $PROJ_DIR_NAME

set PROJ          [lindex $argv 0]
set REV           [lindex $argv 1]
set FAMILY        "Agilex 5"
set DEVICE        "A5EC065BB32AE4S"
set SDC_FILE      [file join $ROOT $ROOT/cons/mxfp_dot.sdc]
set EXP_WIDTH     [lindex $argv 2]
set MAN_WIDTH     [lindex $argv 3]
set PIPE             [lindex $argv 4]

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
# Get Verilog files and SDC file
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/fp_aitb.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/mxfp_dot.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/pipeline.sv]
set_global_assignment -name SDC_FILE [file normalize $SDC_FILE]

# Set number of processors and top design
set_global_assignment -name TOP_LEVEL_ENTITY mxfp_dot
set_global_assignment -name NUM_PARALLEL_PROCESSORS 24
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "output_files_E${EXP_WIDTH}_M$MAN_WIDTH"

# Set virtual pins
set_instance_assignment -name VIRTUAL_PIN ON -to rst -entity mxfp_dot
set_instance_assignment -name VIRTUAL_PIN ON -to load_en -entity mxfp_dot
set_instance_assignment -name VIRTUAL_PIN ON -to valid_in -entity mxfp_dot
set_instance_assignment -name VIRTUAL_PIN ON -to mx_data_in -entity mxfp_dot
set_instance_assignment -name VIRTUAL_PIN ON -to shared_exponent -entity mxfp_dot
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_dot_out -entity mxfp_dot
set_instance_assignment -name VIRTUAL_PIN ON -to valid_out -entity mxfp_dot
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_flags -entity mxfp_dot

# Set parameters
set_parameter -name M     $MAN_WIDTH
set_parameter -name E     $EXP_WIDTH
set_parameter -name PIPE  $PIPE

# Other Assignments
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
set_instance_assignment -name PARTITION_COLOUR 4285333442 -to mxfp_dot -entity mxfp_dot

# Commit assignments
export_assignments

project_close
