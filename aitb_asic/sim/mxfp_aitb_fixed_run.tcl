vlib work

vlog -sv "rtl/pkg_aitb.sv"
vlog -sv "rtl/*.sv"
vlog -sv "rtl/mxfp_dot/*.sv"
vlog -sv "rtl/mxfp_aitb/*.sv"
vlog -sv "rtl/mxfp_aitb/tb_wrappers/*.sv"
vcom "rtl/ieee_fp32_add.vhdl"
vcom "rtl/mxfp_dot/flopoco_normalizers/normalizer_69b.vhdl"

vlog -sv "sim/mxfp_aitb_fixed_tb.sv"

vsim -voptargs=+acc -L tennm_ver work.mxfp_aitb_fixed_tb

run -all

quit
