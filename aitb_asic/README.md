# IV. DSP Block Architecture Modifications

## Description
This is an implementation of an Altera-like AI Tensor Block (AITB) DSP mode configured in FP mode. This DSP mode has a latency of 5 cycles. Other DSP modes are not implemented.

As well as the baseline implementation which closely matches the Altera AITB, there are multiple modified designs which improve the MXFP processing capabilities of the DSP using different approaches.

## Functional Simulation Instructions

Run `source env.sh`.

To run functional simulation for baseline design, run `make sim`.

To run functional simulation for all modified designs, run `make sim_all_mxfp`.

## Generating Table IV

To generate a table similar to table IV from Innovus and COFFE reports, run `make table`.

## Directory structure

> `asic_rpts`: Innovus reports for area and timing of AITB designs
> 
> `coffe_rpts`: COFFE reports for interconnect area
> 
> `hammer_yml`: YML files for HAMMER configuration
> 
> `rtl`: RTL Design files for baseline DSP
>> `mxfp_aitb`: RTL Design files for MXFP dot product (component of MXFP AITB)
>> 
>> `mxfp_dot`: Top level RTL Design files for improved AITB
>> 
> `scripts`: Scripts for running tests/generating tables
> 
> `sim`: Testbenches and associated simulation only files

## Design Naming

Mapping of module names to design iterations in the paper.

| Design Iteration                | Module Name                    |
|---------------------------------|--------------------------------|
| Baseline                        | `aitb`                         |
| (1) Fixed-point inputs          | `fixed_input_mxfp_aitb`        |
| (2) MXFP inputs (all)           | `naive_mxfp_aitb_comp`         |
| (3.1) MXFP inputs (No MXFP8)    | `nofp8_mxfp_aitb_comp`         |
| (3.2) MXFP inputs (No E5M2)     | `noe5m2_mxfp_aitb_comp`        |
| (3.3) MXFP inputs (reduce E5M2) | `e5m2_4_mxfp_aitb_comp`        |
| (4) MXFP inputs (No E5M2)       | `noe5m2_fixed8_mxfp_aitb_comp` |
