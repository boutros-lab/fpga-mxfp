E ?= 2
M ?= 1
PIPE ?= 1
DUT=normalizer

.PHONY: sim fit syn clean

sim:
	vsim -c -do "do sim/${DUT}_run.tcl"

syn:
	hammer-vlsi -p asic/asap7.yml -e asic/asap7.yml --obj_dir asic/obj-dir syn

fit:
	hammer-vlsi -p asic/asap7.yml -e asic/asap7.yml --obj_dir asic/obj-dir syn-par
#	quartus_sh -t syn/setup.tcl mxfp_dot_cli E$E_M$M $E $M ${PIPE}
#	quartus_sh -t syn/fit.tcl mxfp_dot_cli syn E$E_M$M

clean:
	rm *.log *.json asic/obj-dir -r
