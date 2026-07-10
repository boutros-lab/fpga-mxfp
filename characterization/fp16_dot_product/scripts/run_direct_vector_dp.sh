#!/bin/bash
# Script for running synthesis for just direct vector dp

k=32
fp16_mode="bfloat16"
synthesis=true
suffix=""

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -k <value>  Dot product length, default: 32"
    echo "  -t          Suffix for log file (e.g. soft,dsp), none by default"
    echo "  -f <mode>   FP16_mode, one of flushed, extended or bfloat16, bfloat16 by default "
    echo "  -s          Skip synthesis, default: not skipped"
    echo "  -h          Display this help message"
    echo
    echo "Example: $0 -k 32 -s -f extended"
    echo "  Vector length of 32, and fp16_mode of extended"
    echo "  skip synthesis"
    exit 1
}

# Parse command line arguments
while getopts "k:t:f:sh" opt; do
    case ${opt} in
        k )
            k=$OPTARG
            ;;
        t )
            suffix="_$OPTARG"
            ;;
        f )
            fp16_mode="$OPTARG"
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

out="$PROJ_ROOT/logs/direct_dp_results_${fp16_mode}k${k}${suffix}.log"

mkdir -p $PROJ_ROOT/logs/

# Formats and their exponent/mantissa widths
project="direct_vector_dp"
proj_dir="direct_vector_dp"

cd $PROJ_ROOT

echo "Project,Fmax,ALMs,DSPs" > $out

if [ "$synthesis" == true ]; then
	rm -rf ${proj_dirs[$i]}

	# Create Project
	quartus_sh -t $PROJ_ROOT/quartus_tcl/direct_vector_dot_setup.tcl $PROJ_ROOT/$proj_dir $project $project $k $fp16_mode

	# Run synthesis/placement/sta
	quartus_sh -t $PROJ_ROOT/quartus_tcl/run_fit.tcl $project $PROJ_ROOT/$proj_dir
fi

# Extract results to $out
$PROJ_ROOT/scripts/extract_results.sh $project $PROJ_ROOT/$proj_dir/output_files/ >> $out
