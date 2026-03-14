E        ?= 2
M        ?= 1
TESTS    ?= 256
K        ?= 16
PIPE     ?= 1
DUT       = normalizer
DUT_MXFP ?= naive_mxfp_aitb_wrapper

sim:
	vsim -c -do "do sim/${DUT}_run.tcl"

sim_mxfp:
	vsim -c -do "set dut ${DUT_MXFP}; set exp_width $E; set man_width $M; set k $K; set test_length ${TESTS}; do sim/mxfp_aitb_run.tcl"

syn:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/syn.tcl mxfp_dot_cli syn E$E_M$M

fit:
	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli syn E$E_M$M

clean:
	rm -rf work
	rm transcript

.PHONY: sim sim_mxfp fit syn clean
