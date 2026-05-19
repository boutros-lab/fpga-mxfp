E ?= 2
M ?= 1
N ?= 2
IS_FP8_DOT4 ?= 0 

.PHONY: fitaitb fitpacked venv

venv: requirements.txt
	python3 -m venv sa_venv
	sa_venv/bin/pip install -r requirements.txt
	@echo "Venv ready. Run: source sa_venv/bin/activate"

fitaitb:
	quartus_sh -t syn/setup_24_2_aitb.tcl mxfp_dot_cli aitb_E$E_M$M_N$N $E $M $N
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 aitb_E$E_M$M_N$N

fitaitb_prop:
	quartus_sh -t syn/setup_24_2_aitb_prop.tcl mxfp_dot_cli aitb_prop_E$E_M$M_N$N $E $M $N ${IS_FP8_DOT4}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 aitb_prop_E$E_M$M_N$N

fitpacked:
	quartus_sh -t syn/setup_24_2_packed.tcl mxfp_dot_cli packed_E$E_M$M_N$N $E $M $N
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 packed_E$E_M$M_N$N

fitmxfp_dot_prop:
	quartus_sh -t syn/setup_24_2_mxfp_dot_prop.tcl mxfp_dot_cli mxfp_dot_prop_E$E_M$M $E $M ${IS_FP8_DOT4}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 mxfp_dot_prop_E$E_M$M

clean:
	rm -rf build_24_2 *.csv