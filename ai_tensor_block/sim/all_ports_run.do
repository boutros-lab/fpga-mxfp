quit -sim
## vmap altera_mf
#if ![info exists QUARTUS_INSTALL_DIR] { 
#  set QUARTUS_INSTALL_DIR "/tools/altera/quartus-pro/25.3/quartus/"
#}
#
#if ![info exists QUARTUS_SIM_LIB_DIR] { 
#  set QUARTUS_SIM_LIB_DIR "$QUARTUS_INSTALL_DIR/eda/sim_lib/"
#}
#
#if ![info exists DEVICES_SIM_LIB_DIR] { 
#  set DEVICES_SIM_LIB_DIR "$QUARTUS_INSTALL_DIR/../devices/sim_lib/"
#}
## source ../ip/ai_tensor_slice/sim/mentor/msim_setup.tcl
#      vmap lpm "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/lpm"
# vmap tennm_lib "/tools/altera/quartus-pro/25.3/devices/sim_lib2/tennm_lib.map"
# vmap tennm_lib "/tools/altera/quartus-pro/25.3/devices/sim_lib2/"
vmap modelsim_lib "/tools/altera/quartus-pro/25.3/questa_fse/modelsim_lib"
      vmap sgate "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/sgate"
      vmap altera "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/altera"
      vmap altera_mf "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/altera_mf"
      vmap altera_lnsim "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/altera_lnsim"
      vmap tennm "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm"
      vmap tennm_sm_hps "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm_sm_hps"
#      vmap tennm_sm4_hssi "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm_sm_hssi"
#      vmap tennm_revb_hvio "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm_revb_hvio"
#      vmap tennm_revb_io96 "/tools/altera/quartus-pro/25.3/questa_fse/intel/verilog/tennm_revb_io96" 

#source "../ip/ai_tensor_slice/sim/common/modelsim_files.tcl"
#vlog "../ip/ai_tensor_slice/agilex_native_tensor_dsp_100/sim/ai_tensor_slice_agilex_native_tensor_dsp_100_jv5neqi.v"
#vlog "../ip/ai_tensor_slice/agilex_native_tensor_dsp_100/synth/ai_tensor_slice_agilex_native_tensor_dsp_100_immzcpq.v"
vlog "../ip/ai_tensor_slice_all_ports/agilex_native_tensor_dsp_100/sim/ai_tensor_slice_all_ports_agilex_native_tensor_dsp_100_dxcimny.v"
#vlog "../ip/ai_tensor_slice/synth/ai_tensor_slice.v"
vlog "../ip/ai_tensor_slice_all_ports/synth/ai_tensor_slice_all_ports.v"
vlog -sv tensor_all_ports_tb.sv
vsim -voptargs=+acc -L sgate -L altera -L altera_mf -L altera_lnsim -L tennm -L tennm_sm_hps work.tensor_all_ports_tb
do all_ports_wave.do
run -all

#source "../ip/ai_tensor_slice/sim/mentor/msim_setup.tcl"
