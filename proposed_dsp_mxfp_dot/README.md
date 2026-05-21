# MXFP Dot Product Unit Using Proposed DSP Block Design
This directory contains the RTL descriptions instantiating our proposed DSP block to form MXFP dot product units.

## Simulation of MXFP Dot Product Unit
The following command allows simulation of the MXFP dot product unit using our proposed DSP block design with ModelSim:
```bash
$ cd sim
$ bash sweep_sim_mxfp_dot_proposed_modelsim.sh
```

## MXFP Dot Product Unit Resource Utilization and Device Peak Performance
See `systolic_array/README.md` for instructions on how to obtain the results from Table V for the MXFP Dot Product Unit with our proposed DSP block.

## File Descriptions
Descriptions of the sub-directories are given below.

### rtl
RTL descriptions of the dot product units.
- `fp_aitb_proposed.sv`: wrapper module that instantiates either our proposed DSP block's RTL (for behavioural simulation) or the Agilex-5 DSP block IP for implementation in Quartus, as a pin-compatible stand-in. This is controlled by the `IS_SIM` parameter; when `IS_SIM = 1` the DSP block RTL is used, when `IS_SIM = 0` the Agilex-5 DSP block IP is used.
- `mxfp_dot_proposed.sv`: top level dot product wrapper. It instantiates different wrappers depending on the MXFP format chosen, controlled with the `MODE_INT` parameter. See `systolic_array/syn/setup_24_2_mxfp_dot_prop.tcl` for correspondance between MXFP format and MODE_INT value.
- `mxfp_dot_prop_mxfp4.sv`: MXFP4 dot product unit instantiating 2 of our proposed DSP blocks, each perform a dot-16 E2M1 dot product.
- `mxfp_dot_prop_mxfp6.sv`: MXFP6 dot product unit instantiating 3 of our proposed DSP blocks, each perform a dot-12 E2M3 or E3M2 dot product.
- `mxfp_dot_prop_mxfp8.sv`: MXFP8 dot product unit instantiating 4 of our proposed DSP blocks, each perform a dot-8 E4M3 dot product.
- `mxfp_dot_prop_mxfp8_dot4aitb.sv`: MXFP8 dot product unit instantiating 8 of our proposed DSP blocks, each perform a dot-4 E5M2 dot product.

### sim
Testbench for functional verification and simulation scripts.
- `mxfp_dot_proposed_tb.sv`: testbench to verify `mxfp_dot_proposed` module by loading in `NUM_LOADS` sets of vectors followed by streaming in `REUSE_FACTOR` vectors.
- `run_sim_mxfp_dot_proposed_modelsim.sh`: script to setup and run a simulation with QuestaSim/ModelSim of `mxfp_dot_proposed_tb.sv`.
- `sweep_sim_mxfp_dot_proposed_modelsim.sh`: script to run simulations of `mxfp_dot_proposed_tb.sv` for every MXFP format.

Additional Scripts for VCS
- `run_sim_mxfp_dot_proposed_vcs.sh` and `setup_sim_mxfp_dot_proposed_vcs.sh`: scripts to respectively execute a simulation with VCS 2016.06-1 and setup the simulation. To run a simulation: `bash run_sim_mxfp_dot_proposed_vcs.sh`.
- `sweep_sim_mxfp_dot_proposed_vcs.sh`: simulates `mxfp_dot_proposed_tb`, with VCS, with all valid parameter sets providing a summary and log files written in a `logs` sub-directory.