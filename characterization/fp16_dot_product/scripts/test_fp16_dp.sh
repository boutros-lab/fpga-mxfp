#!/bin/bash

rm -rf sim
mkdir sim

cd sim

exp_width=2
man_width=1
k=4
input_stages=1
output_stages=1

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

vmap tennm "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm"

vlog -sv $TB_ROOT/fp16_dp_tb.sv $RTL_ROOT/fp16_dp.sv $RTL_ROOT/mxfp_to_fp.sv \
	$IP_ROOT/sum_of_two/agilex_native_floating_point_dsp_100/synth/sum_of_two_agilex_native_floating_point_dsp_100_pmzaffa.v \
	$IP_ROOT/sum_of_two/synth/sum_of_two.v \
	+define+EXP_WIDTH=$exp_width +define+MAN_WIDTH=$man_width \
	+define+K=$k +define+INPUT_STAGES=$input_stages +define+OUTPUT_STAGES=$output_stages

vsim -voptargs=+acc -L tennm_ver -c work.fp16_dot_tb -do "run -all"

cd ..
