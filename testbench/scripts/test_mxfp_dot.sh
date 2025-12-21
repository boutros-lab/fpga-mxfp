#!/bin/bash

# Script to run mxfp_dot_tb with a specified DUT and test parameters

rm -rf $TB_ROOT/sim
mkdir $TB_ROOT/sim

cd $TB_ROOT/sim

rtl_dir=()
dut_name=
exp_width=2
man_width=1
k=8
test_length=256
tb_name="mxfp_dot_fixed_tb"

# Function to display usage information
usage() {
    echo "Run tests for a specified DUT, MXFP format, and dot product length"
    echo
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -r <value>  RTL directory, all .sv|.v|.h|.vh files will be added, required"
    echo "              Can be used multiple times to add several directories"
    echo "  -d <value>  DUT name, required"
    echo "  -e <value>  Exponent Width, default: 2"
    echo "  -m <value>  Mantissa Width, default: 1"
    echo "  -k <value>  Dot product length, default: 8"
    echo "  -l <value>  Test Length, default: 256"
    echo "  -f          Use FP32 TB, default: fixed point"
    echo "  -h          Display this help message"
    echo
    echo "Example: $0 -f -r \$RTL_ROOT -d dot_fp -e 4 -m 3 -k 32 -l 64"
    echo "  Use FP32 testbench, and dot_fp as the DUT,"
    echo "  add RTL under \$RTL_ROOT, run 64 tests with E4M3 MXFP"
    echo "  and 32 length dot product"
}

# Parse command line arguments
while getopts "r:d:e:m:k:l:fh" opt; do
    case ${opt} in
        r )
		rtl_dir+=("$OPTARG")
		;;
        d )
		dut_name=$OPTARG
		;;
        e )
		exp_width=$OPTARG
		;;
        m )
		man_width=$OPTARG
		;;
        k )
		k=$OPTARG
		;;
        l )
		test_length=$OPTARG
		;;
        f )
		tb_name="mxfp_dot_fp32_tb"
		;;
        h )
		usage
		exit 0
		;;
	?)
		printf "ERROR: Unknown argument ${opt}"
		usage
		exit 2
		;;
    esac
done

if (( ${#rtl_dir[@]} == 0 )); then
	printf "ERROR: No RTL directories set, use -r to set required directories."
	usage
	exit 2
fi

vmap tennm_ver "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm_ver"

# Add all files
for dir in ${rtl_dir[@]}; do
	while IFS= read -r filename; do
		vlog -sv filename
	done < find $dir -type f -name "*.sv" -o -name "*.v" -o -name "*.h" -o -name "*.vh"
done

# Define macros
vlog -sv $TB_ROOT/tb/$tb_name.sv +define+DUT=$dut_name +define+EXP_WIDTH=$exp_width +define+MAN_WIDTH=$man_width \
	                            +define+K=$k +define+TESTS=$test_length +define+DATA_DIR=$TB_ROOT/data

# Run tests
vsim -voptargs=+acc -L tennm_ver -c work.$tb_name -do "run -all"

cd -
