
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

sim-fp16:
	./run_fp16_sim.sh
.PHONY: all base base_opt packed aitb fp16 table
