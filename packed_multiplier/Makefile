DUT ?= packed_dot_product

sim: 
	vlog -sv *.sv 
	vsim -c $(DUT)_tb -do "run -all" -L tennm_ver
	python3 check.py

synth:
	quartus_sh --prepare -f Agilex $(DUT)
	quartus_sh --set DEVICE=A5EC065BB32AE4S $(DUT)
	quartus_sh --flow compile $(DUT)

resynth:
	quartus_sh --flow recompile $(DUT)

clean:
	git clean -dfX