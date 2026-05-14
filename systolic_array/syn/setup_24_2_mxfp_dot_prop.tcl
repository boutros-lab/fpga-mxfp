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
set IS_FP8_DOT4   [lindex $argv 4] 
set IS_SIM 0

if {$EXP_WIDTH == 2} {
	if {$MAN_WIDTH == 1} {
		set MODE 0
	} else {
		set MODE 1
	}
}
if {$EXP_WIDTH == 3} {
	set MODE 2
}
if {$EXP_WIDTH == 4} {
	set MODE 3
}
if {$EXP_WIDTH == 5} {
	set MODE 4
}

set FULL_WIDTH [expr ${MAN_WIDTH}+${EXP_WIDTH}+1]
if {[project_exists $PROJ]} {
    project_open -revision $REV $PROJ
} else {
    project_new $PROJ -revision $REV
}

# Set Family and Device
set_global_assignment -name FAMILY $FAMILY
set_global_assignment -name DEVICE $DEVICE

# Set Quartus Version
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 25.3.0
set_global_assignment -name LAST_QUARTUS_VERSION "25.3.0 Pro Edition"
# Get Verilog files and SDC file
set PROP_MXFP_DOT_RTL [file normalize [file join $ROOT ..  proposed_dsp_mxfp_dot rtl]]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $ROOT rtl pkg_aitb.sv]]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $PROP_MXFP_DOT_RTL fp_aitb_proposed.sv]]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $PROP_MXFP_DOT_RTL mxfp_dot_proposed.sv]]
if {$EXP_WIDTH == 5 && $MAN_WIDTH == 2} {
	if {$IS_FP8_DOT4 == 1} {
		set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $PROP_MXFP_DOT_RTL mxfp_dot_prop_mxfp8_dot4aitb.sv]]
	} else {
		set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $PROP_MXFP_DOT_RTL mxfp_dot_prop_mxfp8.sv]]
	}
} else {
	set_global_assignment -name SYSTEMVERILOG_FILE [file normalize [file join $PROP_MXFP_DOT_RTL mxfp_dot_prop_mxfp${FULL_WIDTH}.sv]]
}
set_global_assignment -name SDC_FILE [file normalize $SDC_FILE]
# Set number of processors and top design
set_global_assignment -name TOP_LEVEL_ENTITY mxfp_dot_proposed
set_global_assignment -name NUM_PARALLEL_PROCESSORS [exec nproc]
if {$EXP_WIDTH == 5 && $MAN_WIDTH == 2 && $IS_FP8_DOT4 == 1} {
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "output_files_mxfp_dot_prop_E${EXP_WIDTH}_M${MAN_WIDTH}_DOT4"
} else {
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "output_files_mxfp_dot_prop_E${EXP_WIDTH}_M${MAN_WIDTH}"
}

# Set virtual pins
set_instance_assignment -name VIRTUAL_PIN ON -to rst -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to load_en_i -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to valid_en_i -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to mx_data_in_i -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to shared_exponent_i -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_dot_out_col1_o -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_dot_out_col2_o -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to valid_out_o -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_flags_col1_o -entity mxfp_dot_proposed
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_flags_col2_o -entity mxfp_dot_proposed


# Set parameters
set_parameter -name M    $MAN_WIDTH
set_parameter -name E    $EXP_WIDTH
set_parameter -name IS_DOT4  $IS_FP8_DOT4
set_parameter -name IS_SIM   $IS_SIM
set_parameter -name MODE_INT $MODE

# Other Assignments
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
set_instance_assignment -name PARTITION_COLOUR 4285333442 -to mxfp_dot_proposed -entity mxfp_dot_proposed

# Commit assignments
export_assignments

project_close
