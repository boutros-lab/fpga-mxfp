E ?= 2
M ?= 1
PIPE ?= 1

.PHONY: sim fit syn

sim:
	vsim -c -do "set M $M" -do "set E $E" -do "do sim/run_dot_aitb.tcl"

syn:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/syn.tcl mxfp_dot_cli syn E$E_M$M

syn242:
	quartus_sh -t syn/setup_24_2.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/syn_24_2.tcl mxfp_dot_cli build_24_2 E2_M1

fit:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli syn E$E_M$M
