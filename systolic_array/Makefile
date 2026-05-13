E ?= 2
M ?= 1
N ?= 2
FP8_DOT4=0

.PHONY: fitaitb fitpacked

syn242aitb:
	quartus_sh -t syn/setup_24_2_aitb.tcl mxfp_dot_cli aitb_E$E_M$M_N$N $E $M $N
	quartus_sh -t syn/syn_24_2.tcl mxfp_dot_cli build_24_2 aitb_E$E_M$M_N$N

syn242packed:
	quartus_sh -t syn/setup_24_2_packed.tcl mxfp_dot_cli packed_E$E_M$M_N$N $E $M $N
	quartus_sh -t syn/syn_24_2.tcl mxfp_dot_cli build_24_2 packed_E$E_M$M_N$N 

fitaitb:
	quartus_sh -t syn/setup_24_2_aitb.tcl mxfp_dot_cli aitb_E$E_M$M_N$N $E $M $N
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 aitb_E$E_M$M_N$N

fitaitb_prop:
	quartus_sh -t syn/setup_24_2_aitb_prop.tcl mxfp_dot_cli aitb_prop_E$E_M$M_N$N $E $M $N ${FP8_DOT4}
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 aitb_prop_E$E_M$M_N$N

fitpacked:
	quartus_sh -t syn/setup_24_2_packed.tcl mxfp_dot_cli packed_E$E_M$M_N$N $E $M $N
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 packed_E$E_M$M_N$N

fitmxfp_dot_prop:
	quartus_sh -t syn/setup_24_2_mxfp_dot_prop.tcl mxfp_dot_cli mxfp_dot_prop_E$E_M$M $E $M
	quartus_sh -t syn/fit.tcl mxfp_dot_cli build_24_2 mxfp_dot_prop_E$E_M$M
