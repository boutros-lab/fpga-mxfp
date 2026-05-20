#!/bin/bash
# Run tests for all formats for a given design, extract results

dut="naive_mxfp_aitb_comp_wrapper"
k=(10 16 12 12 8 8)
exp=(0 2 2 3 4 5)
man=(7 1 3 2 3 2)
fixed_inputs=0

# Function to display usage information
usage() {
	echo "Usage: $0 [options]"
	echo
	echo "Options:"
	echo "  -d <dut_name>   Dut name, default: naive_mxfp_aitb_comp_wrapper"
	echo "  -k \"8 16 12\"  Dot product length of different formats, default: (10 16 12 12  8  8)"
	echo "  -e \"0  2  3\"  Exp width of different formats, default:          ( 0  2  2  3  4  5)"
	echo "  -m \"7  1  2\"  Man width of different formats, default:          ( 7  1  3  2  3  2)"
	echo "  -f              Use fixed_inputs (if DUT expects inputs in FXP), default: false"
	echo "  -h          Display this help message"
	echo
	echo "Example: $0 -d naive_mxfp_aitb_comp_wrapper -k \"16 12\" -e \"2 3\" -m \"1 2\""
	echo "  Run E2M1 and E2M3 with dp lengths of 16 and 12"
	exit 1
}

# Parse command line arguments
while getopts "d:k:e:m:fh" opt; do
	case ${opt} in
		d )
			dut=$OPTARG
			;;
		k )
			read -ra k <<< "$OPTARG"
			;;
		e )
			read -ra exp <<< "$OPTARG"
			;;
		m )
			read -ra man <<< "$OPTARG"
			;;
		f )
			fixed_inputs=1
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

cd $PROJ_ROOT

mkdir -p test_logs
out_log=${dut}_tests.log

echo "START $dut" > $out_log

for ((i=0; i<${#k[@]}; i++)); do
	echo "K: ${k[i]} E: ${exp[i]} M: ${man[i]}" >> $out_log
	make data_and_sim_mxfp DUT_MXFP=${dut} E=${exp[i]} M=${man[i]} K=${k[i]} FIXED_INPUTS=${fixed_inputs} > test_logs/K${k[i]}E${exp[i]}M${man[i]}_${out_log}
	grep -A 3 -e "Simulation PASSED!" -e "Simulation FAILED!" test_logs/K${k[i]}E${exp[i]}M${man[i]}_${out_log} >> $out_log
done

cat $out_log
