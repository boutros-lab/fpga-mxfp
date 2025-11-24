quit -sim
# vmap lpm "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/lpm"
# vmap tennm_lib "/tools/altera/quartus-pro/25.3/devices/sim_lib2/tennm_lib.map"
# vmap tennm_lib "/tools/altera/quartus-pro/25.3/devices/sim_lib2/"
vmap modelsim_lib "/tools/altera/quartus-pro/25.3/questa_fse/modelsim_lib"
vmap sgate "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/sgate"
vmap altera "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/altera"
vmap altera_mf "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/altera_mf"
vmap altera_lnsim "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/altera_lnsim"
vmap tennm "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm"
vmap tennm_sm_hps "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm_sm_hps"

vlog "../ip/ai_tensor_slice/agilex_native_tensor_dsp_100/sim/ai_tensor_slice_agilex_native_tensor_dsp_100_jv5neqi.v"
vlog "../ip/ai_tensor_slice/synth/ai_tensor_slice.v"
vlog -sv tensor_tb.sv
vsim -voptargs=+acc -L sgate -L altera -L altera_mf -L altera_lnsim -L tennm -L tennm_sm_hps work.tensor_tb
do wave.do
run -all


