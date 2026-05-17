vlib work

vlog -sv "../../aitb_asic/rtl/pkg_aitb.sv"
vlog -sv "mxfp_dot_proposed_tb.sv"
vlog -sv "../rtl/mxfp_dot_proposed.sv"
vlog -sv "../rtl/mxfp_dot_prop_mxfp4.sv"
vlog -sv "../rtl/mxfp_dot_prop_mxfp6.sv"
vlog -sv "../rtl/mxfp_dot_prop_mxfp8.sv"
vlog -sv "../rtl/mxfp_dot_prop_mxfp8_dot4aitb.sv"
vlog -sv "../rtl/fp_aitb_proposed.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_aitb/naive_mxfp_aitb_top.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_aitb/config_gen.sv"
vlog -sv "../../aitb_asic/rtl/in_reg_bank.sv"
vlog -sv "../../aitb_asic/rtl/pipeline.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_aitb/input_preparation_mxfp.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_dot/naive_mxfp_dot_fixed.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_dot/config_fix2fp32.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_dot/mxfp_mult_shift.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_dot/naive_reduction.sv"
vlog -sv "../../aitb_asic/rtl/mxfp_dot/mxfp_multiply.sv"

vcom "../../aitb_asic/rtl/ieee_fp32_add.vhdl"
vcom "../../aitb_asic/rtl/mxfp_dot/flopoco_normalizers/normalizer_sgn_70b.vhdl"
vcom "../../aitb_asic/rtl/mxfp_dot/flopoco_shifters/fp8_67_shifter.vhdl"

vsim work.mxfp_dot_proposed_tb -L tennm_ver -voptargs="+acc"
run -all
quit
