# Charaterization

To reproduce Table I, run `make -j3` and wait for the sysnthesis runs to finish. Afterwards, run `make csv` to see the table vizualized. Each CSV file corresponds to a part of Table I as follows:
- `base.csv` → Baseline
- `base_opt.csv` → Baseline Optimized
- `packed_base.csv` → Packed DSP
- `fp16_base.csv` → FP16 Vector Mode
- `aitb_base.csv` → Tensor Mode
