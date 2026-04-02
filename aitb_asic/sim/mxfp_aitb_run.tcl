vlib work

vlog -sv "rtl/pkg_aitb.sv"
vlog -sv "rtl/*.sv"
vlog -sv "rtl/mxfp_dot/*.sv"
vlog -sv "rtl/mxfp_aitb/*.sv"
vlog -sv "rtl/mxfp_aitb/tb_wrappers/*.sv"
vcom "rtl/ieee_fp32_add.vhdl"
vcom "rtl/mxfp_dot/flopoco_normalizers/*.vhdl"
vcom "rtl/mxfp_dot/flopoco_shifters/fp8_67_shifter.vhdl"

vlog -sv "sim/mxfp_aitb_tb.sv" +define+DUT=$dut +define+EXP_WIDTH=$exp_width \
			       +define+MAN_WIDTH=$man_width +define+K=$k +define+TESTS=$test_length \
			       +define+FIXED_INPUTS=$fixed_inputs

vsim -voptargs=+acc -L tennm_ver work.mxfp_aitb_tb

run -all

quit
