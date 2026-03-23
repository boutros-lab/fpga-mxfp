#!/bin/bash

k=32
synthesis=true
suffix=""

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -k <value>  Dot product length, default: 32"
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
while getopts "k:t:sh" opt; do
    case ${opt} in
        k )
            k=$OPTARG
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
projects=("fp16_dot_fp_4" "fp16_dot_fp_6_23" "fp16_dot_fp_6_32" "fp16_dot_fp_8_43" "fp16_dot_fp_8_52")
proj_dirs=("MXFP4" "MXFP6_23" "MXFP6_32" "MXFP8_43" "MXFP8_52")
exp=(2 2 3 4 5)
man=(1 3 2 3 2)

cd $PROJ_ROOT

echo "Project,Fmax,ALMs,DSPs" > $out

for ((i=0; i<${#projects[@]}; i++)); do
	if [ "$synthesis" == true ]; then
		rm -rf ${proj_dirs[$i]}

		# Create Project
		quartus_sh -t $PROJ_ROOT/quartus_tcl/fp16_dot_setup.tcl $PROJ_ROOT/${proj_dirs[$i]} ${projects[$i]} ${projects[$i]} ${exp[$i]} ${man[$i]} $k

		# Run synthesis/placement/sta
		quartus_sh -t $PROJ_ROOT/quartus_tcl/run_fit.tcl ${projects[$i]} $PROJ_ROOT/${proj_dirs[$i]}
	fi

	# Extract results to $out
	$PROJ_ROOT/scripts/extract_results.sh ${projects[$i]} $PROJ_ROOT/${proj_dirs[$i]}/output_files/ >> $out
done
