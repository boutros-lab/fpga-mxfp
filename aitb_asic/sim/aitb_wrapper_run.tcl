vlib work

vlog -sv "rtl/*.sv"
vcom "rtl/ieee_fp32_add.vhdl"

vlog -sv "sim/aitb_wrapper_tb.sv"

vsim -voptargs=+acc -L tennm_ver work.aitb_wrapper_tb

run -all

quit
