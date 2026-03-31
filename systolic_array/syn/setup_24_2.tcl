package require ::quartus::project

# Quartus seemed to like more if build_dir is separate
set ROOT [pwd]
set BUILD_DIR [file join $ROOT build_24_2]
file mkdir $BUILD_DIR
cd $BUILD_DIR

set PROJ       [lindex $argv 0]
set REV        [lindex $argv 1]
set FAMILY     "Agilex 5"
set DEVICE     "A5EC065BB32AE4S"
set SDC_FILE   [file join $ROOT cons sys_array_aitb.sdc]
set EXP_WIDTH  [lindex $argv 2]
set MAN_WIDTH  [lindex $argv 3]

if {[project_exists $PROJ]} {
    project_open -revision $REV $PROJ
} else {
    project_new $PROJ -revision $REV
}

# Set Family and Device
set_global_assignment -name FAMILY $FAMILY
set_global_assignment -name DEVICE $DEVICE

# Set Quartus Version
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 24.2.0
set_global_assignment -name LAST_QUARTUS_VERSION "24.2.0 Pro Edition"
# Get Verilog files and SDC file
set MXFP_DOT_RTL [file normalize [file join $ROOT .. ai_tensor_block rtl]]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $ROOT rtl sys_array_aitb.sv]]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $MXFP_DOT_RTL fp_aitb.sv]]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $MXFP_DOT_RTL mxfp_dot.sv]]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $MXFP_DOT_RTL pipeline.sv]]
set_global_assignment -name SDC_FILE [file normalize $SDC_FILE]

# Set number of processors and top design
set_global_assignment -name TOP_LEVEL_ENTITY sys_array_aitb
set_global_assignment -name NUM_PARALLEL_PROCESSORS 24
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "output_files_E${EXP_WIDTH}_M${MAN_WIDTH}"

# Set virtual pins
set_instance_assignment -name VIRTUAL_PIN ON -to rst -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to is_load_phase_i -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to load_en_all_i -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to weight_left_i -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to weight_shared_exp_left_i -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to valid_top_i -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to x_top_i -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to x_shared_exp_top_i -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to dot_fp32_col1_o -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to dot_fp32_col2_o -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to valid_o -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_flags_col1_o -entity sys_array_aitb
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_flags_col2_o -entity sys_array_aitb


# Set parameters
set_parameter -name MAN_W    $MAN_WIDTH
set_parameter -name EXP_W    $EXP_WIDTH

# Other Assignments
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
set_instance_assignment -name PARTITION_COLOUR 4285333442 -to sys_array_aitb -entity sys_array_aitb

# Commit assignments
export_assignments

project_close
