vlib work
vlog -sv "mxfp_gen.sv"
vsim work.mxfp_gen -voptargs="+acc"
run -all
#do fp_ai_tb_wave.do
#quit
