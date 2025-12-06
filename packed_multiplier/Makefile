sim: 
	vlog -sv packed_multiplier.sv packed_multiplier_tb.sv
	vsim -c packed_multiplier_tb -do "run -all"

synth:
	quartus_sh --flow compile packed_multiplier

clean:
	git clean -dfX