# Copyright (C) 2025  Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, the Altera Quartus Prime License Agreement,
# the Altera IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Altera and sold by Altera or its authorized distributors.  Please
# refer to the Altera Software License Subscription Agreements 
# on the Quartus Prime software download page.

# Quartus Prime: Generate Tcl File for Project
# File: dot_fp_4.tcl
# Generated on: Tue Nov 18 18:30:56 2025

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "dot_fp_4"]} {
		puts "Project dot_fp_4 is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists dot_fp_4]} {
		project_open -revision dot_fp_4 dot_fp_4
	} else {
		project_new -revision dot_fp_4 dot_fp_4
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name TOP_LEVEL_ENTITY dot_fp_staged
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 25.3.0
	#set_global_assignment -name PROJECT_CREATION_TIME_DATE "14:23:52  NOVEMBER 05, 2025"
	set_global_assignment -name LAST_QUARTUS_VERSION "25.3.0 Pro Edition"
	set_global_assignment -name SYSTEMVERILOG_FILE "../MX-for-FPGA/src/dot/dot_fp_staged.sv"
	set_global_assignment -name SYSTEMVERILOG_FILE "../MX-for-FPGA/src/util/arith/vec_sum_int.sv"
	set_global_assignment -name SYSTEMVERILOG_FILE "../MX-for-FPGA/src/util/arith/vec_mul_fp.sv"
	set_global_assignment -name SYSTEMVERILOG_FILE "../MX-for-FPGA/src/util/arith/mul_int.sv"
	set_global_assignment -name SYSTEMVERILOG_FILE "../MX-for-FPGA/src/util/arith/mul_fp.sv"
	set_global_assignment -name SDC_FILE "../MX-for-FPGA/src/dot/SDC/fp4.sdc"
	set_global_assignment -name SYSTEMVERILOG_FILE "../MX-for-FPGA/src/dot/dot_fp.sv"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name DEVICE A5EC065BB32AE4S
	set_global_assignment -name FAMILY "Agilex 5"
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
	set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
	set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
	set_instance_assignment -name VIRTUAL_PIN ON -to i_vec_a -entity dot_fp_staged
	set_instance_assignment -name VIRTUAL_PIN ON -to i_vec_b -entity dot_fp_staged
	set_instance_assignment -name VIRTUAL_PIN ON -to o_dp_q -entity dot_fp_staged
	set_instance_assignment -name VIRTUAL_PIN ON -to rst -entity dot_fp_staged
	set_instance_assignment -name PARTITION_COLOUR 4285333442 -to dot_fp_4 -entity dot_fp_staged
	set_parameter -name exp_width 2
	set_parameter -name man_width 1
	set_parameter -name k         8

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
