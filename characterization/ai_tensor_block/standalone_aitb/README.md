To simulate the standalone fixed point AI tensor block (fxp\_aitb), launch Questa using the following command:
```shell
$ vsim&
```

In Questa's command prompt, run the following commands:
```shell
Questa> cd <rtl_directory>
Questa> vlib work
Questa> vlog fxp_aitb.sv fxp_aitb_tb.sv
Questa> vsim work.fxp_aitb_tb -L tennm_ver -voptargs="+acc"
Questa> run -all
```

The expected output of the simulation should look like the following:
```shell
# Results are matching: result0=     -19248, golden0=     -19248, result1=     -15311, golden1=     -15311
# Results are matching: result0=      -7673, golden0=      -7673, result1=      16509, golden1=      16509
# Results are matching: result0=      -9713, golden0=      -9713, result1=     -15020, golden1=     -15020
# Results are matching: result0=     -12130, golden0=     -12130, result1=     -21840, golden1=     -21840
# Results are matching: result0=       9157, golden0=       9157, result1=      -1762, golden1=      -1762
# Simulation PASSED!
# ** Note: $stop    : fxp_aitb_tb.sv(131)
```
