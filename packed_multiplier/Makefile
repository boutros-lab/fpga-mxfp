DUT ?= packed_dot_product_fp32
E ?= 5
M ?= 2
FLOPOCO_VHDL = flopoco_fx2fp_pipelined/mxfp_e$(E)m$(M)_to_fp32.vhdl

sim: 
	vcom $(FLOPOCO_VHDL)
	vlog -sv *.sv 
	vsim -c $(DUT)_tb -Gexponent_width=$(E) -Gmantissa_width=$(M) -do "run -all" -L tennm_ver
	python3 check.py

sim_all:
	@for em in "2 1" "2 3" "3 2" "4 3" "5 2"; do \
		set -- $$em; \
		echo "=== Testing E$$1M$$2 ==="; \
		$(MAKE) sim DUT=$(DUT) E=$$1 M=$$2 || exit 1; \
	done
	
synth:
	quartus_sh --prepare -f Agilex $(DUT)
	quartus_sh --set DEVICE=A5EC065BB32AE4S $(DUT)
	quartus_sh --set VHDL_FILE=$(FLOPOCO_VHDL) $(DUT)
	echo 'set_instance_assignment -name VIRTUAL_PIN ON -to *' >> $(DUT).qsf
	quartus_sh --flow compile $(DUT)

clean:
	git clean -dfX