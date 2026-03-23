DUT ?= packed_dot_product

sim: 
	vcom flopoco_fx2fp_pipelined/*.vhdl
	vlog -sv *.sv 
	vsim -c $(DUT)_tb -do "run -all" -L tennm_ver
	python3 check.py

sim_all_fp32:
	vcom flopoco_fx2fp_pipelined/*.vhdl
	vlog -sv *.sv
	@echo "=== Testing E2M1 ==="
	vsim -c packed_dot_product_fp32_tb -Gexponent_width=2 -Gmantissa_width=1 -do "run -all" -L tennm_ver
	python3 check.py
	@echo "=== Testing E2M3 ==="
	vsim -c packed_dot_product_fp32_tb -Gexponent_width=2 -Gmantissa_width=3 -do "run -all" -L tennm_ver
	python3 check.py
	@echo "=== Testing E3M2 ==="
	vsim -c packed_dot_product_fp32_tb -Gexponent_width=3 -Gmantissa_width=2 -do "run -all" -L tennm_ver
	python3 check.py
	@echo "=== Testing E4M3 ==="
	vsim -c packed_dot_product_fp32_tb -Gexponent_width=4 -Gmantissa_width=3 -do "run -all" -L tennm_ver
	python3 check.py
	@echo "=== Testing E5M2 ==="
	vsim -c packed_dot_product_fp32_tb -Gexponent_width=5 -Gmantissa_width=2 -do "run -all" -L tennm_ver
	python3 check.py
	
synth:
	quartus_sh --prepare -f Agilex $(DUT)
	quartus_sh --set DEVICE=A5EC065BB32AE4S $(DUT)
	quartus_sh --set VHDL_FILE=flopoco_fx2fp_pipelined/mxfp_e2m1_to_fp32.vhdl $(DUT)
	quartus_sh --set VHDL_FILE=flopoco_fx2fp_pipelined/mxfp_e2m3_to_fp32.vhdl $(DUT)
	quartus_sh --set VHDL_FILE=flopoco_fx2fp_pipelined/mxfp_e3m2_to_fp32.vhdl $(DUT)
	quartus_sh --set VHDL_FILE=flopoco_fx2fp_pipelined/mxfp_e4m3_to_fp32.vhdl $(DUT)
	quartus_sh --set VHDL_FILE=flopoco_fx2fp_pipelined/mxfp_e5m2_to_fp32.vhdl $(DUT)
	echo 'set_instance_assignment -name VIRTUAL_PIN ON -to *' >> $(DUT).qsf
	quartus_sh --flow compile $(DUT)

clean:
	git clean -dfX