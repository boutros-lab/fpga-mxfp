#!/bin/csh -f

if ( -d sim) then
    cd sim
else
    mkdir sim && cd sim
endif

set MX_ROOT="/home/msmekhem/lp_dsp/MX-for-FPGA"
set RTL_ROOT="/home/msmekhem/lp_dsp/rtl"
set TB_ROOT="/home/msmekhem/lp_dsp/tb"

set mul_int="$RTL_ROOT/mul_int.sv"

set exp_width     = 2
set man_width     = 1
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

xvlog --sv -svlog $TB_ROOT/dot_fp_tb.sv $RTL_ROOT/dot_fp_staged.sv $RTL_ROOT/pipeline.sv $MX_ROOT/src/dot/dot_fp.sv $MX_ROOT/src/util/arith/vec_mul_fp.sv $MX_ROOT/src/util/arith/vec_sum_int.sv $MX_ROOT/src/util/arith/mul_fp.sv $mul_int -d EXP_WIDTH=$exp_width -d MAN_WIDTH=$man_width -d K=$k -d INPUT_STAGES=$input_stages -d OUTPUT_STAGES=$output_stages
xelab work.dot_fp_tb -R

cd ..
