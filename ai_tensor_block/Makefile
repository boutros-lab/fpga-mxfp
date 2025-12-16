E ?= 2
M ?= 1
PIPE ?= 1

fit:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli syn E$E_M$M
