.TITLE Dedicated Routing Driver

********************************************************************************
** Include libraries, parameters and other
********************************************************************************

.LIB "../includes.l" INCLUDES

********************************************************************************
** Setup and input
********************************************************************************

.TRAN 1p 4n SWEEP DATA=sweep_data
.OPTIONS BRIEF=1

* Input signal
VIN n_in gnd PULSE (0 supply_v 0 0 0 2n 4n)

* Power rail for the circuit under test.
* This allows us to measure power of a circuit under test without measuring the power of wave shaping and load circuitry.
V_TEST vdd_test gnd supply_v

********************************************************************************
** Measurement
********************************************************************************

* inv_hard_block_ddriver_1 delay
.MEASURE TRAN meas_inv_hard_block_ddriver_1_tfall TRIG V(n_1_1) VAL='supply_v/2' RISE=1
+    TARG V(Xdriver.n_1_2) VAL='supply_v/2' FALL=1
.MEASURE TRAN meas_inv_hard_block_ddriver_1_trise TRIG V(n_1_1) VAL='supply_v/2' FALL=1
+    TARG V(Xdriver.n_1_2) VAL='supply_v/2' RISE=1

* inv_hard_block_ddriver_2 delays
.MEASURE TRAN meas_inv_hard_block_ddriver_2_tfall TRIG V(n_1_1) VAL='supply_v/2' FALL=1
+    TARG V(Xdriver.n_1_4) VAL='supply_v/2' FALL=1
.MEASURE TRAN meas_inv_hard_block_ddriver_2_trise TRIG V(n_1_1) VAL='supply_v/2' RISE=1
+    TARG V(Xdriver.n_1_4) VAL='supply_v/2' RISE=1

* inv_hard_block_ddriver_3 delay
.MEASURE TRAN meas_inv_hard_block_ddriver_3_tfall TRIG V(n_1_1) VAL='supply_v/2' RISE=1
+    TARG V(Xdriver.n_1_6) VAL='supply_v/2' FALL=1
.MEASURE TRAN meas_inv_hard_block_ddriver_3_trise TRIG V(n_1_1) VAL='supply_v/2' FALL=1
+    TARG V(Xdriver.n_1_6) VAL='supply_v/2' RISE=1

* inv_hard_block_ddriver_4 delays
.MEASURE TRAN meas_inv_hard_block_ddriver_4_tfall TRIG V(n_1_1) VAL='supply_v/2' FALL=1
+    TARG V(Xdriver.n_out) VAL='supply_v/2' FALL=1
.MEASURE TRAN meas_inv_hard_block_ddriver_4_trise TRIG V(n_1_1) VAL='supply_v/2' RISE=1
+    TARG V(Xdriver.n_out) VAL='supply_v/2' RISE=1

* Total delays
.MEASURE TRAN meas_total_tfall TRIG V(n_1_1) VAL='supply_v/2' FALL=1
+    TARG V(n_1_3) VAL='supply_v/2' FALL=1
.MEASURE TRAN meas_total_trise TRIG V(n_1_1) VAL='supply_v/2' RISE=1
+    TARG V(n_1_3) VAL='supply_v/2' RISE=1

.MEASURE TRAN meas_logic_low_voltage FIND V(gnd) AT=3n

* Measure the power required to propagate a rise and a fall transition through the subcircuit at 250MHz.
.MEASURE TRAN meas_current INTEGRAL I(V_TEST) FROM=0ns TO=4ns
.MEASURE TRAN meas_avg_power PARAM = '-((meas_current)/4n)*supply_v'

********************************************************************************
** Circuit
********************************************************************************

Xinv_ff_output_driver_0 n_in n_1_0 vdd gnd inv Wn=inv_ff_output_driver_nmos Wp=inv_ff_output_driver_pmos
Xinv_ff_output_driver n_1_0 n_1_1 vdd gnd inv Wn=inv_ff_output_driver_nmos Wp=inv_ff_output_driver_pmos
Xdriver n_1_1 n_1_2 vdd_test gnd hard_block_ddriver
Xwirer_edi n_1_2 n_1_3 wire Rw=wire_hard_block_2_res Cw=wire_hard_block_2_cap 
Xff n_1_3 n_hang2 vdd gnd vdd nnd gnd vdd gnd vdd vdd gnd ff
.END