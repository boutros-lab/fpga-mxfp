#!/bin/bash

rm -rf sim
mkdir sim

cd sim

MXROOT="/home/msmekhem/lp_dsp/MX-for-FPGA"
RTLROOT="/home/msmekhem/lp_dsp/rtl"
TBROOT="/home/msmekhem/lp_dsp/tb"

mul_int="$RTLROOT/mul_int.sv"

exp_width=2
man_width=1
k=8
input_stages=1
output_stages=1

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -e <value>  Exponent Width, default: 2"
    echo "  -m <value>  Mantissa Width, default: 1"
    echo "  -k <value>  Dot product length, default: 8"
    echo "  -i <value>  Input Register Stages, default: 1"
    echo "  -o <value>  Output Register Stages, default: 1"
    echo "  -h          Display this help message"
    echo
    echo "Example: $0 -e 4 -m 3 -k 32 -i 4 -o 3"
    echo "  Run test with E4M3 32 length dot product,"
    echo "  4 input register stages and 3 output"
    echo "  register stages"
    exit 1
}

# Parse command line arguments
while getopts "e:m:k:i:o:h" opt; do
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
        h )
            usage
            ;;
    esac
done

vlog -sv $TBROOT/dot_fp_tb.sv $RTLROOT/dot_fp_staged.sv $RTLROOT/pipeline.sv $MXROOT/src/dot/dot_fp.sv $MXROOT/src/util/arith/vec_mul_fp.sv \
	$MXROOT/src/util/arith/vec_sum_int.sv $MXROOT/src/util/arith/mul_fp.sv $mul_int +define+EXP_WIDTH=$exp_width +define+MAN_WIDTH=$man_width \
	+define+K=$k +define+INPUT_STAGES=$input_stages +define+OUTPUT_STAGES=$output_stages
vsim -c work.dot_fp_tb -do "run -all"

cd ..
