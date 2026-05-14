#!/bin/bash

PIPE=$1
k=32
input_stages=1
dot_fp_stages=$1
pipeline_add=$1
pipeline_flopoco=$1
fp32_stages=$1
output_stages=1
mul_int="$RTL_ROOT/mul_int.sv"
synthesis=true
suffix=""

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -k <value>  Dot product length, default: 8"
    echo "  -i <value>  Input register stages, default: 1"
    echo "  -d <value>  Dot FP register stages, default: 1"
    echo "  -a <value>  Pipeline adder tree, default: 1"
    echo "  -p <value>  Use pipelined fix2fp, default: 1"
    echo "  -f <value>  FP32 register stages, default: 1"
    echo "  -o <value>  Output register stages, default: 1"
    echo "  -m <path>   Path to mul_int.sv, default: $RTL_ROOT/mul_int.sv"
    echo "  -t          Suffix for log file (e.g. soft,dsp), none by default"
    echo "  -s          Skip synthesis, default: not skipped"
    echo "  -h          Display this help message"
    echo
    echo "Example: $0 -k 32 -s -m 2 -t dsp"
    echo "  Run all MXFP formats with a vector length of 32,"
    echo "  skip synthesis, mult_style DSP, append _dsp to log file"
    exit 1
}

# Parse command line arguments
while getopts "k:i:d:a:p:f:o:m:t:sh" opt; do
    case ${opt} in
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
	m )
	    mul_int=$OPTARG
	    ;;
        t )
            suffix="_$OPTARG"
            ;;
        s )
            synthesis=false
            ;;
        h )
            usage
	    exit 0
            ;;
	* )
	    echo "Unexpected flag, ${opt}"
	    usage
	    exit 1
	    ;;
    esac
done

out="$PROJ_ROOT/logs/results_${k}${suffix}.log"

mkdir -p $PROJ_ROOT/logs/

# Formats and their exponent/mantissa widths
projects=("dot_fp_4" "dot_fp_6_23" "dot_fp_6_32" "dot_fp_8_43" "dot_fp_8_52")
proj_dirs=("MXFP4" "MXFP6_23" "MXFP6_32" "MXFP8_43" "MXFP8_52")
exp=(2 2 3 4 5)
man=(1 3 2 3 2)

cd $PROJ_ROOT

echo "Project,Fmax,ALMs,DSPs" > $out

for ((i=0; i<${#projects[@]}; i++)); do
	if [ "$synthesis" == true ]; then
		rm -rf ${proj_dirs[$i]}

		# Create Project
		quartus_sh -t $PROJ_ROOT/quartus_tcl/dot_setup_fp32.tcl $PROJ_ROOT/${proj_dirs[$i]} ${projects[$i]} ${projects[$i]} ${exp[$i]} ${man[$i]} $k $input_stages $dot_fp_stages $pipeline_add $fp32_stages $output_stages $mul_int $pipeline_flopoco

		# Run synthesis/placement/sta
		quartus_sh -t $PROJ_ROOT/quartus_tcl/run_fit.tcl ${projects[$i]} $PROJ_ROOT/${proj_dirs[$i]}
	fi

	# Extract results to $out
	$PROJ_ROOT/scripts/extract_results.sh ${projects[$i]} $PROJ_ROOT/${proj_dirs[$i]}/output_files/ >> $out
done
