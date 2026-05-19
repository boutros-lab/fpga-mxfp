#!/usr/bin/env python3
import csv
import sys

# Agilex 5 constants
TOTAL_ALM = 222400
TOTAL_DSP = 846

MX_BLOCK_SIZE = 32

NUM_DOTS_PROP = 2

def main():
    csv_path = sys.argv[1] if len(sys.argv) > 1 else "mxfp_dot_prop_sweep.csv"

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
            rows.append((fmt, fmax, alms, dsps))

    col_w = [max(len(h), max(len(str(r[i])) for r in rows)) for i, h in enumerate(["Format", "Fmax_MHz", "ALMs", "DSPs"])]
    headers = ["Format", "Fmax_MHz", "ALMs", "DSPs"]
    header_line = "  ".join(h.ljust(col_w[i]) for i, h in enumerate(headers))
    sep = "  ".join("-" * col_w[i] for i in range(len(headers)))

    print(header_line)
    print(sep)
    for fmt, fmax, alms, dsps in rows:
        vals = [fmt, str(fmax), str(alms), str(dsps)]
        print("  ".join(v.ljust(col_w[i]) for i, v in enumerate(vals)))

if __name__ == "__main__":
    main()
