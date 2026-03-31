E ?= 2
M ?= 1

.PHONY: sim syn242

sim:
	vsim -c -do "set M $M" -do "set E $E" -do "do sim/run_dot_aitb.tcl"

syn242aitb:
	quartus_sh -t syn/setup_24_2_aitb.tcl mxfp_dot_cli E$E_M$M $E $M
	quartus_sh -t syn/syn_24_2.tcl mxfp_dot_cli build_24_2 E2_M1

# Hardcoded exp and man since it requires different module to be compiled.
# just to test it passes the flow
syn242packed:
	quartus_sh -t syn/setup_24_2_packed.tcl mxfp_dot_cli E4_M3 4 3
	quartus_sh -t syn/syn_24_2.tcl mxfp_dot_cli build_24_2 E4_M3

fitaitb:
	quartus_sh -t syn/setup_24_2_aitb.tcl mxfp_dot_cli E$E_M$M $E $M
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 E$E_M$M

fitpacked:
	quartus_sh -t syn/setup_24_2_packed.tcl mxfp_dot_cli E4_M3 4 3
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 E4_M3
