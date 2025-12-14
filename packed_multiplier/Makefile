DUT ?= packed_multiplier

sim: 
	vlog -sv DSP_sim.sv $(DUT).sv $(DUT)_tb.sv 
	vsim -c $(DUT)_tb -do "run -all"

synth:
	quartus_sh --prepare -f Agilex $(DUT)
	quartus_sh --set DEVICE=A5EC065BB32AE4S $(DUT)
	quartus_sh --flow compile $(DUT)

resynth:
	quartus_sh --flow recompile $(DUT)

clean:
	git clean -dfX