
all: base base_opt packed aitb fp16
sim-all: sim-base sim-base_opt sim-packed sim-fp16 sim-aitb

base:
	./run_base.sh

base_opt: base
	./run_base_opt.sh

packed:
	./run_packed.sh

fp16:
	./run_fp16.sh

aitb:
	./run_aitb.sh

table:
	@./csv_viz.sh

sim-base:
	./run_base_sim.sh

sim-base_opt:
	./run_base_opt_sim.sh

sim-packed:
	./run_packed_sim.sh

sim-fp16:
	./run_fp16_sim.sh

sim-aitb:
	./run_aitb_sim.sh


.PHONY: all base base_opt packed aitb fp16 table sim-packed sim-fp16 sim-aitb sim-base sim-base_opt sim-all
