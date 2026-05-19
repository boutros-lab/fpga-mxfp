#!/usr/bin/env python3
import csv
import math
import sys
import os, subprocess

# Agilex 5 constants
TOTAL_ALM = 222400
TOTAL_DSP = 846

MX_BLOCK_SIZE = 32

NUM_DOTS_PROP = 2

# MULT + ADD
NUM_OPS = 2

def compute_tflops(alms, dsps, fmax_mhz, num_dots=NUM_DOTS_PROP, dot_size=MX_BLOCK_SIZE):
    if alms <= 0:
        return 0.0
    alm_limited = math.floor(TOTAL_ALM / alms)
    dsp_divisor = dsps if dsps != 0 else 0.0001
    dsp_limited = math.floor(TOTAL_DSP / dsp_divisor)
    units = min(alm_limited, dsp_limited)
    # MHz * 2 ops / 1e6 -> TFLOPs
    return units * num_dots * fmax_mhz * dot_size * NUM_OPS / 1_000_000

def main():
    csv_path = sys.argv[1] if len(sys.argv) > 1 else "mxfp_dot_prop_sweep.csv"

    if not os.path.exists(csv_path):
        print("Running run_sweep_mxfp_dot_prop.sh")
        subprocess.run(["bash", "run_sweep_mxfp_dot_prop.sh"], check=True)

    rows = []
    with open(csv_path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            fmt = row["Format"]
            fmax = float(row["Fmax_MHz"])
            alms_total = int(row["ALMs_used_total"])
            alms_vio = int(row["ALMs_VIRTUAL_IO"])
            dsps = int(row["DSP_blocks"])
            alms = alms_total - alms_vio
            d = NUM_DOTS_PROP
            tflops = compute_tflops(alms, dsps, fmax, num_dots=d)
            rows.append((fmt, fmax, alms, dsps, d, tflops))

    headers = ["Format", "Fmax_MHz", "ALMs", "DSPs", "D", "TFLOPS"]
    str_rows = [[fmt, f"{fmax:.1f}", str(alms), str(dsps), str(d), f"{tflops:.1f}"]
                for fmt, fmax, alms, dsps, d, tflops in rows]

    col_w = [max(len(h), max(len(r[i]) for r in str_rows)) for i, h in enumerate(headers)]
    header_line = "  ".join(h.ljust(col_w[i]) for i, h in enumerate(headers))
    sep = "  ".join("-" * col_w[i] for i in range(len(headers)))

    print("Resource utilization and device peak performance with our proposed DSP block.")
    print(header_line)
    print(sep)
    for r in str_rows:
        print("  ".join(v.ljust(col_w[i]) for i, v in enumerate(r)))

if __name__ == "__main__":
    main()