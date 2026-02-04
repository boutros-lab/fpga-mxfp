#set E [lindex $argv end-1]
#set M [lindex $argv end]

puts "Running for E${E}M$M"

vlib work
vlog -sv "rtl/fp_aitb.sv"
vlog -sv "rtl/pipeline.sv"
vlog -sv "rtl/mxfp_dot.sv"
vlog -sv +define+E=$E +define+M=$M "sim/mxfp_dot_tb.sv"
vsim work.mxfp_dot_tb -L tennm_ver -voptargs="+acc"
run -all
#do mxfp_dot_wave.do
quit
