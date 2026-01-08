E ?= 2
M ?= 1
PIPE ?= 1

.PHONY: sim fit

sim:
	vsim -c -do "set M $M" -do "set E $E" -do "do sim/run_dot_aitb.tcl"

fit:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli syn E$E_M$M
