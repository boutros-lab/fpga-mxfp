DIR   ?=
DUT   ?=
E     ?= 2
M     ?= 1
K     ?= 32
TESTS ?= 256
FP32  ?= 0

# Extra options
DATA_OPTS ?=
SIM_OPTS  ?=

data:
	$(TB_ROOT)/scripts/generate_data.py -e $(E) -m $(M) -k $(K) -t $(TESTS) $(DATA_OPTS)

sim:
	if [ $(FP32) -eq 1 ]; then \
		$(TB_ROOT)/scripts/test_mxfp_dot.sh -r $(DIR) -d $(DUT) -e $(E) -m $(M) -k $(K) -l $(TESTS) $(SIM_OPTS) -f; \
	else \
		$(TB_ROOT)/scripts/test_mxfp_dot.sh -r $(DIR) -d $(DUT) -e $(E) -m $(M) -k $(K) -l $(TESTS) $(SIM_OPTS); \
	fi

data_and_sim: data sim

clean:
	rm -rf $(TB_ROOT)/data
	rm -rf $(TB_ROOT)/sim

.PHONY: data sim data_and_sim clean
