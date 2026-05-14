
all: base base_opt packed aitb

base:
	./run_base.sh

base_opt: base
	./run_base_opt.sh

packed:
	./run_packed.sh

aitb:
	./run_aitb.sh

csv:
	@./csv_viz.sh *.csv

.PHONY: all base base_opt packed aitb csv
