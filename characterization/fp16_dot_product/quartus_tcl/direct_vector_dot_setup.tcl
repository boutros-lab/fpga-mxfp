# For testing only direct vector DP
# 0: Project Directory
# 1: Project Name
# 2: Project Revision
# 3: K
# 4: FP16_MODE

package require ::quartus::project

set PROJ_DIR_NAME   [lindex $argv 0]
file mkdir $PROJ_DIR_NAME

set ROOT [pwd]

cd $PROJ_DIR_NAME

set PROJ          [lindex $argv 1]
set REV           [lindex $argv 2]
set FAMILY        "Agilex 5"
set DEVICE        "A5EC065BB32AE4S"
set SDC_FILE      [file join $ROOT $ROOT/quartus_tcl/mx_dp.sdc]
set K             [lindex $argv 3]
set FP16_MODE     [lindex $argv 4]

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
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/direct_vector_dp.sv]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/ip/sum_of_two.v]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/ip/vector_one.v]
set_global_assignment -name SYSTEMVERILOG_FILE [file normalize $ROOT/rtl/ip/vector_two.v]
set_global_assignment -name SDC_FILE [file normalize $SDC_FILE]

# Set number of processors and top design
set_global_assignment -name TOP_LEVEL_ENTITY direct_vector_dp
set_global_assignment -name NUM_PARALLEL_PROCESSORS 24
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "output_files"

# Set virtual pins
set_instance_assignment -name VIRTUAL_PIN ON -to rst -entity direct_vector_dp
set_instance_assignment -name VIRTUAL_PIN ON -to fp16_in_a -entity direct_vector_dp
set_instance_assignment -name VIRTUAL_PIN ON -to fp16_in_b -entity direct_vector_dp
set_instance_assignment -name VIRTUAL_PIN ON -to fp32_out -entity direct_vector_dp

# Set parameters
set_parameter -name k         $K
set_parameter -name FP16_MODE $FP16_MODE

# Other Assignments
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name PWRMGT_VOLTAGE_OUTPUT_FORMAT "LINEAR FORMAT"
set_global_assignment -name PWRMGT_LINEAR_FORMAT_N "-12"
set_global_assignment -name POWER_APPLY_THERMAL_MARGIN ADDITIONAL
set_instance_assignment -name PARTITION_COLOUR 4285333442 -to direct_vector_dp -entity direct_vector_dp

# Commit assignments
export_assignments

project_close

