*** PROCESS DATA AND VOLTAGE LEVELS

.LIB PROCESS_DATA

* Voltage levels
.PARAM supply_v = 0.8
.PARAM sram_v = 1.0
.PARAM sram_n_v = 0.0
.PARAM Rcurrent = 1.5e-06
.PARAM supply_v_lp = 0.95

.PARAM sense_v = 0.9199999999999999

.PARAM mtj_worst_high = 4840.0
.PARAM mtj_worst_low = 3060.0
.PARAM mtj_nominal_low = 2500.0

.PARAM mtj_nominal_high = 6250

.PARAM vref = 0.627
.PARAM vclmp = 0.653
* Geometry
.PARAM gate_length = 20n
.PARAM trans_diffusion_length = 25.0n
.PARAM min_tran_width = 7n
.param rest_length_factor=10

* Supply voltage.
VSUPPLY vdd gnd supply_v
VSUPPLYLP vdd_lp gnd supply_v_lp
* SRAM voltages connecting to gates
VSRAM vsram gnd sram_v
VrefMTJn vrefmtj gnd vref
Vclmomtjn vclmpmtj gnd vclmp
VSRAM_N vsram_n gnd sram_n_v

* Device models
.LIB "/home/aelsousy/COFFE/spice_models/7nm_TT_160803.l" 7NM_FINFET_HP

.ENDL PROCESS_DATA