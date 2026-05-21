# III. Characterization Study

The implementations characterized in this study are organized into the following directories:

| Directory Name                   | Implementation Approach |
|----------------------------------|-------------------------|
| `imperial_benchmark_exploration` | Baseline                |
| `imperial_benchmark_exploration` | Baseline Optimized      |
| `packed_multiplier`              | Packed DSP              |
| `fp16_dot_product`               | FP16 Vector Mode        |
| `ai_tensor_block`                | Tensor Mode             |

To reproduce the characterization results, run `make` and wait for the synthesis runs to finish. Use `make -j4` to run in parallel (needs >40GB RAM). CSV files will be produced corresponding to the implementation approaches as follows:

| CSV File          | Implementation Approach  |
|-------------------|--------------------------|
| `base.csv`        | Baseline                 |
| `base_opt.csv`    | Baseline Optimized       |
| `packed_base.csv` | Packed DSP               |
| `fp16_base.csv`   | FP16 Vector Mode         |
| `aitb_base.csv`   | Tensor Mode              |

Afterwards, run `make table` to generate a visualization similar to Table 1. Then, run `make tflops` to calculate TFLOPS for each implementation and generate a visualization similar to Figure 3.

To check functional correctness, run `make sim-all` to run a functional simulation check for all implementations. Run `make sim-{base|base_opt|packed|fp16|aitb}` if you want to check each implementation's correctness on its own. Logs for each implementation's run can be found under the implementation's directory.
