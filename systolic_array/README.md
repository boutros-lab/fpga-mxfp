# MXFP-based Systolic Arrays on Agilex-5
This directory contains systolic array implementations to perform matrix multiplication using MXFP on Agilex-5.

## Simulation of Systolic Array Designs
The following command allows simulation of the systolic array designs using the baseline AITB (E2M1 and E2M3) with ModelSim:
```bash
$ cd sim
$ bash sweep_sim_sys_array_aitb_modelsim.sh
```

The following command allows simulation of the systolic array designs using the baseline DSP, packed approach, (E3M2, E4M3 and E5M2) with ModelSim:
```bash
$ cd sim
$ bash sweep_sim_sys_array_packed_modelsim.sh
```

The following command allows simulation of the systolic array designs using our proposed DSP (all formats) with ModelSim:
```bash
$ cd sim
$ bash sweep_sim_sys_array_aitb_prop_modelsim.sh
```
**Warning:** for MXFP6 and MXFP8 simulations, Questa Altera Edition limit for instances is surpassed (warning suppressed in the aforementioned sweep script).

## MXFP Dot Product Unit Resource Utilization and Device Peak Performance
To obtain the results from Table V for the MXFP Dot Product Unit with our proposed DSP block, run:
```bash
$ python3 summarize_mxfp_dot_prop_sweep.py
```
**Note:** This can take approximately 1-2 hours.
The above Python file will run the `run_sweep_mxfp_dot_prop.sh` script, running Quartus, if the CSV result file is not already generated. Then, the Python script will summarize the results in a table in the terminal.

## Systolic Array Designs Performance Results
To obtain the results from Figure 6 for the performance results for the systolic array design targeting the baseline Agilex-5 DSP block and our proposed DSP block, run:
```bash
$ make venv
$ source sa_venv/bin/activate
(sa_venv)$ python summarize_systolic_array_sweep.py
```
**Note:** This can take approximately 4 hours.
The above Python file will run `run_sweep_aitb.sh`, `run_sweep_packed.sh` and `run_sweep_prop.sh` in parallel if their respective CSV result files are not already generated. Then, the Python script will parse the results to re-create the performance result prop (`sa_tflops_sweep.pdf`). The virtual environnment installs `matplotlib`, which is used for the plot generation.

## File Descriptions
Descriptions of the sub-directories are given below.

### cons
Conatins the `sdc` used with Quartus to evaluate utilization and timing of the systolic arrays.

### rtl
RTL descriptions of the systolic arrays. The systolic arrays implement matrix
multiplications. The matrix multiplication is between a $N \times k$ matrix and a $k \times (N \times D)$ matrix, where $k = 32$ (MXFP block size) and $D$ is the number of 32-element MXFP dot product operations computed per processing element (PE).
- `sys_array_aitb_prop.sv`: systolic array design whose PE is a MXFP dot product unit using our proposed DSP block. See the `proposed_dsp_mxfp_dot` directory for details on the dot product unit using our proposed DSP block. $D = 2$.
- `sys_array_aitb.sv`: systolic array design whose PE is a MXFP dot product unit using the Agilex-5 DSP block configured in tensor mode (for E2M3 and E2M1 MXFP formats). $D = 2$.
- `sys_array_packed_mult.sv`: systolic array design whose PE is a MXFP dot product unit using the Agilex-5 DSP block with the "Packed Fixed-Point Multiplier" approach (E3M2, E4M3 and E5M2 formats). $D = NUM\_OPS$.

### sim
Testbenches for functional verification and simulation scripts.
- `sys_array_aitb_prop_tb.sv`: testbench to verify `sys_array_aitb_prop` module by loading in a set of vectors from a "weight" matrix followed by streaming "P" sets of "activation" vectors.
- `sys_array_aitb_tb.sv`: testbench to verify `sys_array_aitb` module by loading in a set of vectors from a "weight" matrix followed by streaming "P" sets of "activation" vectors.
- `sys_array_packed_mult_tb.sv`: testbench to verify `sys_array_packed_mult` module by streaming "P" sets of "weight" and "activation" vectors to the systolic array.

For each of the three systolic arrays (and their testbench), a pair of "run" and "setup" scripts exist to run a the testbench for a systolic array with VCS (VCS 2016.06-1 was used). The run script uses the related setup script. A pair of scripts also exist to run the mxfp_dot module from the AITB characterization.

Three "sweep" scripts exist to simulate the corresponding three sytolic arrays with their supported MXFP formats. Outputs of simulations appear in a `logs` sub-directory.

### syn