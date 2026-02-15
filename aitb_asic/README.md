# Aletra-like AI Tensor Block Implementation

## Description
This is an implementation of an Altera-like AI Tensor Block DSP mode configured in FP mode. This DSP mode has a latency of 5 cycles. 

### Loading Mechanism
Loading is managed by 2 seperate sets of buffers (8bx10), controlled by the 2 signals `load_bb_one` and `load_bb_two` each corresponding to a set of buffers. Each of these buffers feed the 2 columns (dot engines) with operands. The `load_bb_*` signals are registered. They should be asserted then provide the data to be stored in them via the `data_in` port in the next clock cycle. 

## Directory structure

## Microarchitecture

Diagram

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
