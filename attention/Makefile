DUT ?= transpose

sim:
	vlog -sv *.sv
	vsim -c $(DUT)_tb -do "run -all"
	python3 check.py

clean:
	git clean -dfX
