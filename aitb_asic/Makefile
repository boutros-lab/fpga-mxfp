E         ?= 2
M         ?= 1
TESTS     ?= 256
K         ?= 16
PIPE      ?= 1
DUT        = aitb_wrapper
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
	hammer-vlsi -p hammer_yml/${ASIC_YML}.yml -e hammer_yml/${ASIC_YML}.yml --obj_dir hammer_yml/${ASIC_YML}_${TIMESTAMP}_obj-dir syn

fit:
	hammer-vlsi -p hammer_yml/${ASIC_YML}.yml -e hammer_yml/${ASIC_YML}.yml --obj_dir hammer_yml/${ASIC_YML}_${TIMESTAMP}_obj-dir syn-par

sim_all_mxfp:
	PROJ_ROOT=$(CURDIR) ./scripts/run_all_designs.sh

table:
	PROJ_ROOT=$(CURDIR) ./scripts/get_asic_results.sh

clean:
	rm -f *.log *.csv *.json hammer_yml/obj-dir -r
	rm -rf work
	rm -rf data
	rm -f transcript
	rm -rf test_logs

clean_asic:
	rm -rf hammer_yml/*obj-dir

.PHONY: sim sim_mxfp data_and_sim_mxfp fit syn sim_all_mxfp table clean clean_asic
