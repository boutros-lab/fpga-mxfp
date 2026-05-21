vlib work
vlog fxp_aitb.sv fxp_aitb_tb.sv
vsim work.fxp_aitb_tb -L tennm_ver -voptargs="+acc"
run -all
#quit
