vlog -sv "rtl/pkg_aitb.sv"
vlog -sv "rtl/normalizer.sv"
vlog -sv "rtl/fix2fp32.sv"
vlog -sv "sim/fix2fp32_tb.sv"

vsim -voptargs=+acc work.fix2fp32_tb
run -all
quit
