# MXFP-based Systolic Arrays on Agilex-5
This directory contains systolic array implementations to perform matrix multiplication using MXFP on Agilex-5.

Descriptions of the sub-directories are given below.

## cons
Conatins the `sdc` used with Quartus to evaluate utilization and timing of the systolic arrays.

## rtl
RTL descriptions of the systolic arrays.
- `sys_array_aitb_prop.sv`: systolic array design whose PE is a MXFP dot product unit using our proposed DSP block.
- `sys_array_aitb.sv`: systolic array design whose PE is a MXFP dot product unit using the Agilex-5 DSP block configured in tensor mode (for E2M3 and E2M1 MXFP formats).
- `sys_array_packed_mult.sv`: systolic array design whose PE is a MXFP dot product unit using the Agilex-5 DSP block with the "Packed Fixed-Point Multiplier" approach (E3M2, E4M3 and E5M2 formats).

## sim

## syn