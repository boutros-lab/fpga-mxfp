vlog -sv "rtl/pkg_aitb.sv"
vlog -sv "rtl/normalizer.sv"
vlog -sv "sim/normalizer_tb.sv"

vsim -voptargs=+acc work.normalizer_tb
run -all
quit
