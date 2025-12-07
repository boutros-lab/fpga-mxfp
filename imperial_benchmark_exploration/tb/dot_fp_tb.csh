#!/bin/csh -f

if ( -d sim) then
    cd sim
else
    mkdir sim && cd sim
endif

set MXROOT="/home/msmekhem/lp_dsp/MX-for-FPGA"
set RTLROOT="/home/msmekhem/lp_dsp/rtl"
set TBROOT="/home/msmekhem/lp_dsp/tb"

set mul_int="$RTLROOT/mul_int.sv"

set exp_width     = 2
set man_width     = 2
set k             = 8
set input_stages  = 1
set output_stages = 1

while ( $#argv > 0 )
    switch ( $argv[1] )
        case "-e":
            set exp_width = $argv[2]
            shift argv
            break
        case "-m":
            set man_width = $argv[2]
            shift argv
            break
        case "-k":
            set k = $argv[2]
            shift argv
            break
        case "-i":
            set input_stages = $argv[2]
            shift argv
            break
        case "-o":
            set output_stages = $argv[2]
            shift argv
            break
        case "--":
            shift argv
            breaksw
        default:
            echo "Unknown option: $argv[1]"
            exit 1
    endsw
    shift argv
end

xvlog --sv -svlog $TBROOT/dot_fp_tb.sv $RTLROOT/dot_fp_staged.sv $RTLROOT/pipeline.sv $MXROOT/src/dot/dot_fp.sv $MXROOT/src/util/arith/vec_mul_fp.sv $MXROOT/src/util/arith/vec_sum_int.sv $MXROOT/src/util/arith/mul_fp.sv $mul_int -d EXP_WIDTH=$exp_width -d MAN_WIDTH=$man_width -d K=$k -d INPUT_STAGES=$input_stages -d OUTPUT_STAGES=$output_stages
xelab work.dot_fp_tb -R

cd ..
