#!/bin/bash

rm -rf sim
mkdir sim

cd sim

k=32
test_length=1

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -k <value>  Dot product length, default: 32"
    echo "  -t <value>  Test length, default: 1"
    echo "  -h          Display this help message"
    echo
    echo "Example: $0 -k 32 -t 64"
    echo "  dot product length of 32, test length of 64"
    exit 1
}

# Parse command line arguments
while getopts "k:t:h" opt; do
    case ${opt} in
        k )
            k=$OPTARG
            ;;
	t )
            test_length=$OPTARG
            ;;
        h )
            usage
            ;;
    esac
done

vmap tennm "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm"

vlog -sv $TB_ROOT/bf16_dp_tb.sv $RTL_ROOT/direct_vector_dp.sv \
	$IP_ROOT/sum_of_two.v $IP_ROOT/vector_one.v $IP_ROOT/vector_two.v \
	+define+K=$k +define+TESTS=$test_length

vsim -voptargs=+acc -L tennm_ver -c work.bf16_dp_tb -do "log -r /*; run -all; quit -f"

cd ..
