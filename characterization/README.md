# III. Characterization Study

To reproduce the characterization results, run `make` and wait for the synthesis runs to finish. Use `make -j4` to run in parallel (needs >40GB RAM). CSV files will be produced corresponding to the implementation approaches as follows:

| CSV File          | Implementation Approach  |
|-------------------|--------------------------|
| `base.csv`        | Baseline                 |
| `base_opt.csv`    | Baseline Optimized       |
| `packed_base.csv` | Packed DSP               |
| `fp16_base.csv`   | FP16 Vector Mode         |
| `aitb_base.csv`   | Tensor Mode              |

Afterwards, run `make table` to generate a visualization similar to Table 1. 