## IV. DSP Block Architecture Modifications

# Design Naming

| Design Iteration                | Module Name                    |
|---------------------------------|--------------------------------|
| (1) Fixed-point inputs          | `fixed_input_mxfp_aitb`        |
| (2) MXFP inputs (all)           | `naive_mxfp_aitb_comp`         |
| (3.1) MXFP inputs (No MXFP8)    | `nofp8_mxfp_aitb_comp`         |
| (3.2) MXFP inputs (No E5M2)     | `noe5m2_mxfp_aitb_comp`        |
| (3.3) MXFP inputs (reduce E5M2) | `e5m2_4_mxfp_aitb_comp`        |
| (4) MXFP inputs (No E5M2)       | `noe5m2_fixed8_mxfp_aitb_comp` |

# Functional Simulation Instructions

To run functional simulation for baseline design, run `make sim`
To run functional simulation for all improved designs, run `make sim_all_mxfp`

# Generating Table IV

To generate a table similar to table IV from Innovus and COFFE report, run `make table`

## Aletra-like AI Tensor Block Implementation

## Description
This is an implementation of an Altera-like AI Tensor Block DSP mode configured in FP mode. This DSP mode has a latency of 5 cycles. 

### Loading Mechanism
Loading is managed by 2 seperate sets of buffers (8bx10), controlled by the 2 signals `load_bb_one` and `load_bb_two` each corresponding to a set of buffers. Each of these buffers feed the 2 columns (dot engines) with operands. The `load_bb_*` signals are registered. They should be asserted then provide the data to be stored in them via the `data_in` port in the next clock cycle. 

## Directory structure

`asic_rpts/`: Innovus reports for area and timing of AITB designs
`coffe_rpts/`: COFFE reports for interconnect area
`hammer_yml/`: YML files for HAMMER configuration
`rtl/`: RTL Design files
`rtl/mxfp_dot/`: RTL Design files for mxfp dot product
`rtl/mxfp_aitb/`: Top level RTL Design files for improved AITB
`scripts/`: Scripts for running tests/generating tables
`sim/`: TB files

## Microarchitecture

### Modules

I. `in_reg_bank`: Input Register Bank

**I/O**
1. `clk`: clock
2. `rst`: active-high reset
3. `data_in`: input data vectors
4. `data_in_sh_exp`: shared exponent input port
5. `load_bb_one`: registered active-high load enable for buffer set 1
6. `load_bb_two`: registered active-high load enable for buffer set 2
7. `load_buf_sel`: registered select signal to select which buffer set to use for computation
8. `w_reg_c1`: operands to be used by the first column of the DSP
9. `w_reg_c1_sh_exp`: shared exponent to be used by the first column of the DSP
10. `w_reg_c2`: operands to be used by the second column of the DSP
11. `w_reg_c2_sh_exp`: shared exponent to be used by the second column of the DSP
---
II. `dot.sv`: Dot Engine

**I/O**:
1. `data_in`: 1st input input data vector
2. `w_reg`: 2nd input data vector
3. `data_in_sh_exp`: 1st input shared exponent
4. `w_reg_shared_exp`: 2nd input shared exponent
5. `dot_out`: dot product of 1st and 2nd inputs
6. `sh_exp_out`: dot product shared exponent
---

III. CPA

**NOTE** This is a carry propoagate adder that is used for accumulation in the AITB's fixed point mode. However it exists in the FP mode as a passthrough.
---
IV. `fix2fp32.sv`: Fix to FP32 converter

**I/O**
1. `fixed_in`: Fixed point input 
2. `shared_exp`: Shared exponent input
3. `fp32_out`: Output packed in FP32

**NOTE** The `fix2fp32` module includes a normalizer that counts the number of leading zeros and shifts the fixed point number to be an FP32 mantissa. The number of leading zeros is used to adjust the exponent to be an FP32 exponent.
---
V. `ieee_fp32_add.vhdl` Flopoco-generated IEEE single-precision FP32 adder
**I/O**
1. `X`: First operand
2. `Y`: Second operand
3. `R`: Output results (X+Y)
---

### Design Notes
- There is a `pipeline.sv` module. This is just a module that encapsulates the pipeline register logic.
 
## Running the ASIC flow
 1. Double check that all the files you need are listed under `synthesis.inputs.input_files` in `asic/asap7.yml`. Note the that is a YAML style list.
 2. Load Genus and Innovus modules
 3. Activate the conda environment with `conda activate hammer`.
 4. Run `make fit` for running the full ASIC flow (RTL to GDSII)
 5. Check the files `asic/obj-dir/par-rundir/{area|timing}.rpt` for area and timing results.
