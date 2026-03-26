E         ?= 2
M         ?= 1
TESTS     ?= 256
K         ?= 16
PIPE      ?= 1
DUT        = normalizer
DUT_MXFP  ?= naive_mxfp_aitb_wrapper
DATA_OPTS ?=
ASIC_YML  ?= base

sim:
	vsim -c -do "do sim/${DUT}_run.tcl"

sim_mxfp:
	vsim -c -do "set dut ${DUT_MXFP}; set exp_width $E; set man_width $M; set k $K; set test_length ${TESTS}; do sim/mxfp_aitb_run.tcl"

data_and_sim_mxfp:
	PROJ_ROOT=$(CURDIR) ../testbench/scripts/generate_data.py --common_vec -e $(E) -m $(M) -k $(K) -t $(TESTS) $(DATA_OPTS)
	vsim -c -do "set dut ${DUT_MXFP}; set exp_width $E; set man_width $M; set k $K; set test_length ${TESTS}; do sim/mxfp_aitb_run.tcl"

syn:
	hammer-vlsi -p asic/${ASIC_YML}.yml -e asic/${ASIC_YML}.yml --obj_dir asic/${ASIC_YML}_obj-dir syn
#	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
#	quartus_sh -t syn/syn.tcl mxfp_dot_cli syn E$E_M$M

fit:
	hammer-vlsi -p asic/${ASIC_YML}.yml -e asic/${ASIC_YML}.yml --obj_dir asic/${ASIC_YML}_obj-dir syn-par
#	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
#	quartus_sh -t syn/fit.tcl mxfp_dot_cli syn E$E_M$M

clean:
	rm -f *.log *.json asic/obj-dir -r
	rm -rf work
	rm -rf data
	rm -f transcript

clean_asic:
	rm -rf asic/*obj-dir

.PHONY: sim sim_mxfp data_and_sim_mxfp fit syn clean clean_asic
