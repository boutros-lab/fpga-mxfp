E     ?= 2
M     ?= 1
K     ?= 32
TESTS ?= 256

# Extra options
DATA_OPTS ?=
SIM_OPTS  ?=

data:
	PROJ_ROOT=$(CURDIR) ../testbench/scripts/generate_data.py -e $(E) -m $(M) -k $(K) -t $(TESTS) $(DATA_OPTS)

sim:
	./scripts/test_fp16_mxfp_dp.sh -e $(E) -m $(M) -k $(K) -t $(TESTS) $(SIM_OPTS)

data_and_sim: data sim

syn:
	./scripts/run_all_formats.sh -k $(K)

clean:
	rm -rf data
	rm -rf sim
	rm -rf MXFP*

.PHONY: data sim data_and_sim syn clean
