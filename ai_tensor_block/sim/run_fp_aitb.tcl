vlib work
vlog -sv "../rtl/fp_aitb.sv"
vlog -sv "fp_aitb_tb.sv"
vsim work.fp_aitb_tb -L tennm_ver -voptargs="+acc"
#run -all
#do fp_ai_tb_wave.do
#quit
