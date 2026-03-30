DUT ?= transpose

MX_SRC = ../imperial_benchmark_exploration/MX-for-FPGA/src

sim:
	vlog -sv *.sv \
		$(MX_SRC)/util/clz_int.sv \
		$(MX_SRC)/util/rnd/fp_rnd_rne.sv \
		$(MX_SRC)/util/unsigned_max.sv \
		$(MX_SRC)/convert/conv_bf16tomxfp.sv
	vsim -c $(DUT)_tb -do "run -all"
	python3 check.py

clean:
	git clean -dfX
