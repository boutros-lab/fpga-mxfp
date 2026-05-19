*** BASIC SUBCIRCUITS

.LIB BASIC_SUBCIRCUITS

******************************************************************************************
* Interconnect wire
******************************************************************************************
.SUBCKT wire n_in n_out Rw=1 Cw=1
CWIRE_1 n_in gnd Cw
RWIRE_1 n_in n_out Rw
CWIRE_2 n_out gnd Cw
.ENDS


******************************************************************************************
* Pass-transistor
******************************************************************************************
.SUBCKT ptran n_in n_out n_gate n_gnd Wn=1
MNPASS n_in n_gate n_out n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* PMOS Pass-transistor
******************************************************************************************
.SUBCKT ptranp n_in n_out n_gate n_vdd Wn=1
MPPASS n_in n_gate n_out n_vdd pmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* Transmission gate
******************************************************************************************
.SUBCKT tgate n_in n_out n_gate_nmos n_gate_pmos n_vdd n_gnd Wn=1 Wp=1
MNTGATE n_in n_gate_nmos n_out n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPTGATE n_in n_gate_pmos n_out n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* Transmission gate
******************************************************************************************
.SUBCKT tgate_lp n_in n_out n_gate_nmos n_gate_pmos n_vdd n_gnd Wn=1 Wp=1
MNTGATE n_in n_gate_nmos n_out n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPTGATE n_in n_gate_pmos n_out n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* Level-restorer PMOS
******************************************************************************************
.SUBCKT rest n_pull n_gate n_vdd n_gnd Wp=1 
MPREST n_pull n_gate n_vdd n_vdd pmos L=gate_length*rest_length_factor nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* Inverter
******************************************************************************************
.SUBCKT inv n_in n_out n_vdd n_gnd Wn=1 Wp=1
MNDOWN n_out n_in n_gnd n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPUP n_out n_in n_vdd n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* Low Power Inverter
******************************************************************************************
.SUBCKT inv_lp n_in n_out n_vdd n_gnd Wn=1 Wp=1
MNDOWN n_out n_in n_gnd n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPUP n_out n_in n_vdd n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* nand2
******************************************************************************************
.SUBCKT nand2 n_in n_out n_vdd n_gnd Wn=1 Wp=1
MNDOWN2 n_out n_vdd n_z n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MNDOWN1 n_z n_in n_gnd n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPUP1 n_out n_vdd n_vdd n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
MPUP2 n_out n_in n_vdd n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* nand2
******************************************************************************************
.SUBCKT nand2_lp n_in n_out n_vdd n_gnd Wn=1 Wp=1
MNDOWN2 n_out n_vdd n_z n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MNDOWN1 n_z n_in n_gnd n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPUP1 n_out n_vdd n_vdd n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
MPUP2 n_out n_in n_vdd n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* nand3
******************************************************************************************
.SUBCKT nand3 n_in n_out n_vdd n_gnd Wn=1 Wp=1
MNDOWN2 n_out n_vdd n_z n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MNDOWN1 n_z n_vdd n_z2 n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MNDOWN0 n_z2 n_in n_gnd n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPUP0 n_out n_vdd n_vdd n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
MPUP1 n_out n_vdd n_vdd n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
MPUP2 n_out n_in n_vdd n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* nand3
******************************************************************************************
.SUBCKT nand3_lp n_in n_out n_vdd n_gnd Wn=1 Wp=1
MNDOWN2 n_out n_vdd n_z n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MNDOWN1 n_z n_vdd n_z2 n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MNDOWN0 n_z2 n_in n_gnd n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPUP0 n_out n_vdd n_vdd n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
MPUP1 n_out n_vdd n_vdd n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
MPUP2 n_out n_in n_vdd n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* Transmission gate
******************************************************************************************
.SUBCKT RAM_tgate n_in n_out n_gate_nmos n_gate_pmos n_vdd n_gnd Wn=1 Wp=1
MNTGATE n_in n_gate_nmos n_out n_gnd nmos L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPTGATE n_in n_gate_pmos n_out n_vdd pmos L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


******************************************************************************************
* Transmission gate
******************************************************************************************
.SUBCKT RAM_tgate_lp n_in n_out n_gate_nmos n_gate_pmos n_vdd n_gnd Wn=1 Wp=1
MNTGATE n_in n_gate_nmos n_out n_gnd nmos_lp L=gate_length nfin=Wn ASEO=Wn*min_tran_width*trans_diffusion_length ADEO=Wn*min_tran_width*trans_diffusion_length PSEO='Wn*(min_tran_width+2*trans_diffusion_length)' PDEO='Wn*(min_tran_width+2*trans_diffusion_length)'
MPTGATE n_in n_gate_pmos n_out n_vdd pmos_lp L=gate_length nfin=Wp ASEO=Wp*min_tran_width*trans_diffusion_length ADEO=Wp*min_tran_width*trans_diffusion_length PSEO='Wp*(min_tran_width+2*trans_diffusion_length)' PDEO='Wp*(min_tran_width+2*trans_diffusion_length)'
.ENDS


.ENDL BASIC_SUBCIRCUITS