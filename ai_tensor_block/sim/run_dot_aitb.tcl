vlib work
vlog -sv "../rtl/fp_aitb.sv"
vlog -sv "../rtl/pipeline.sv"
vlog -sv "../rtl/mxfp_dot.sv"
vlog -sv "mxfp_dot_tb.sv"
vsim work.mxfp_dot_tb -L tennm_ver -voptargs="+acc"
run -all
do mxfp_dot_wave.do
#quit
