E         ?= 2
M         ?= 1
TESTS     ?= 256
K         ?= 16
PIPE      ?= 1
DUT        = normalizer
DUT_MXFP  ?= naive_mxfp_aitb_comp_wrapper
DATA_OPTS ?=
ASIC_YML  ?= base
TIMESTAMP := $(shell date +%m_%d_%H_%M)
FIXED_INPUTS ?= 0

sim:
	vsim -c -do "do sim/${DUT}_run.tcl"

sim_mxfp:
	vsim -c -do "set dut ${DUT_MXFP}; set exp_width $E; set man_width $M; set k $K; set test_length ${TESTS}; set fixed_inputs ${FIXED_INPUTS}; do sim/mxfp_aitb_run.tcl"

data_and_sim_mxfp:
	PROJ_ROOT=$(CURDIR) ../testbench/scripts/generate_data.py --common_vec -e $(E) -m $(M) -k $(K) -t $(TESTS) $(DATA_OPTS)
	$(MAKE) sim_mxfp
syn:
	hammer-vlsi -p asic/${ASIC_YML}.yml -e asic/${ASIC_YML}.yml --obj_dir asic/${ASIC_YML}_${TIMESTAMP}_obj-dir syn

fit:
	hammer-vlsi -p asic/${ASIC_YML}.yml -e asic/${ASIC_YML}.yml --obj_dir asic/${ASIC_YML}_${TIMESTAMP}_obj-dir syn-par

clean:
	rm -f *.log *.json asic/obj-dir -r
	rm -rf work
	rm -rf data
	rm -f transcript

clean_asic:
	rm -rf asic/*obj-dir

.PHONY: sim sim_mxfp data_and_sim_mxfp fit syn clean clean_asic
