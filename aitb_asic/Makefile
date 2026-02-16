E ?= 2
M ?= 1
PIPE ?= 1
DUT=normalizer

.PHONY: sim fit syn

sim:
	vsim -c -do "do sim/${DUT}_run.tcl"

syn:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/syn.tcl mxfp_dot_cli syn E$E_M$M

fit:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli syn E$E_M$M
