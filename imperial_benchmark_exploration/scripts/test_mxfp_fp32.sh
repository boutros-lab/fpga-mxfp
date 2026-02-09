#!/bin/bash

rm -rf sim
mkdir sim

cd sim

mul_int="$RTL_ROOT/mul_int.sv"

exp_width=2
man_width=1
k=32
input_stages=1
dot_fp_stages=1
pipeline_add=1
pipeline_flopoco=1
fp32_stages=1
output_stages=1
test_length=256

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -e <value>  Exponent Width, default: 2"
    echo "  -m <value>  Mantissa Width, default: 1"
    echo "  -k <value>  Dot product length, default: 8"
    echo "  -i <value>  Input Register Stages, default: 1"
    echo "  -d <value>  Dot FP Register Stages, default: 1"
    echo "  -a <value>  Pipeline adder tree, default: 1"
    echo "  -p <value>  Use pipelined fix2fp, default: 1"
    echo "  -f <value>  FP Register Stages, default: 1"
    echo "  -o <value>  Output Register Stages, default: 1"
    echo "  -t <value>  Test Length, default: 256"
    echo "  -h          Display this help message"
    echo
    echo "Example: $0 -e 4 -m 3 -k 32 -i 4 -o 3 -t 64"
    echo "  Run test with E4M3 32 length dot product,"
    echo "  4 input register stages and 3 output"
    echo "  register stages, tests length of 64"
    exit 1
}

# Parse command line arguments
while getopts "e:m:k:i:d:a:p:f:o:t:h" opt; do
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
        d )
	    dot_fp_stages=$OPTARG
            ;;
        a )
	    pipeline_add=$OPTARG
            ;;
        p )
	    pipeline_flopoco=$OPTARG
            ;;
        f )
            fp32_stages=$OPTARG
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

# Add Flopoco file
if [ $pipeline_flopoco -eq 1 ] 
then
	vcom $FL_ROOT/pipelined/mxfp_e${exp_width}m${man_width}_to_fp32.vhdl
else
	vcom $FL_ROOT/combinational/mxfp_e${exp_width}m${man_width}_to_fp32.vhdl
fi

vlog -sv $TB_ROOT/mxfp_dot_fp32_tb.sv $RTL_ROOT/dot_fp_fp32.sv $RTL_ROOT/pipeline.sv $RTL_ROOT/dot_fp.sv $MX_ROOT/src/util/arith/vec_mul_fp.sv \
	$RTL_ROOT/vec_sum_int.sv $MX_ROOT/src/util/arith/mul_fp.sv $mul_int +define+EXP_WIDTH=$exp_width +define+MAN_WIDTH=$man_width \
	+define+K=$k +define+INPUT_STAGES=$input_stages +define+DOT_FP_STAGES=$dot_fp_stages +define+PIPELINE_ADD=$pipeline_add +define+FP32_STAGES=$fp32_stages \
	+define+OUTPUT_STAGES=$output_stages +define+TESTS=$test_length +define+DATA_DIR=$test +define+PIPELINE_FLOPOCO=$pipeline_flopoco

vsim -c work.mxfp_dot_tb -do "run -all"

cd ..
