
all: base base_opt packed aitb fp16

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

sim-packed:
	./run_packed_sim.sh

sim-fp16:
	./run_fp16_sim.sh

sim-aitb:
	./run_fp16_aitb.sh


.PHONY: all base base_opt packed aitb fp16 table
