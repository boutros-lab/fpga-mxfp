# MXFP Dot Product Unit Using Proposed DSP Block Design
This directory contains the RTL descriptions instantiating our proposed DSP block to form MXFP dot product units.

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
- `run_sim_mxfp_dot_proposed_vcs.sh` and `setup_sim_mxfp_dot_proposed_vcs.sh`: scripts to simulate `mxfp_dot_proposed_tb` with VCS 2016.06-1. To run the simulation: `bash run_sim_mxfp_dot_proposed_vcs.sh`.

See the `systolic_array` directory for details on simulating `mxfp_dot_proposed_tb` using ModelSim/QuestaSim.