#!/bin/bash

rm -rf sim
mkdir sim

cd sim

exp_width=2
man_width=1
k=2
input_stages=1
output_stages=1
test_length=8

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -e <value>  Exponent Width, default: 2"
    echo "  -m <value>  Mantissa Width, default: 1"
    echo "  -k <value>  Dot product length, default: 4"
    echo "  -i <value>  Input Register Stages, default: 1"
    echo "  -o <value>  Output Register Stages, default: 1"
    echo "  -h          Display this help message"
    echo
    echo "Example: $0 -e 4 -m 3 -k 32 -i 4 -o 3 -t 64"
    echo "  Run test with E4M3 32 length dot product,"
    echo "  4 input register stages and 3 output"
    echo "  register stages, test length of 64"
    exit 1
}

# Parse command line arguments
while getopts "e:m:k:i:o:t:h" opt; do
    case ${opt} in
        e )
            exp_width=$OPTARG
            ;;
        m )
            man_width=$OPTARG
            ;;
        k )
            k=$OPTARG
            ;;
        i )
            input_stages=$OPTARG
            ;;
        o )
            output_stages=$OPTARG
            ;;        
	t )
            test_length=$OPTARG
            ;;
        h )
            usage
            ;;
    esac
done

test="$PROJ_ROOT/data"

vmap tennm "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm"

vlog -sv $TB_ROOT/fp16_mxfp_dp_tb.sv $RTL_ROOT/fp16_mxfp_dp.sv $RTL_ROOT/mxfp_to_fp.sv \
	$RTL_ROOT/add_shared_exp.sv $RTL_ROOT/pipeline.sv $RTL_ROOT/direct_vector_dp.sv \
	$IP_ROOT/sum_of_two.v $IP_ROOT/vector_one.v $IP_ROOT/vector_two.v  $IP_ROOT/fp32_add.v $RTL_ROOT/tb_wrappers/fp16_mxfp_dp_wrapper.sv \
	+define+EXP_WIDTH=$exp_width +define+MAN_WIDTH=$man_width \
	+define+K=$k +define+INPUT_STAGES=$input_stages +define+OUTPUT_STAGES=$output_stages +define+TESTS=$test_length +define+DATA_DIR=$test

vsim -voptargs=+acc -L tennm_ver -c work.fp16_mxfp_dp_tb -do "run -all"

cd ..
