import csv
import math
import os
import matplotlib.pyplot as plt
import numpy as np

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# Device constants
TOTAL_ALMS = 222_400
TOTAL_DSPS = 846
DOT_SIZE = 32

# Format order
FORMATS = ["E5M2", "E4M3", "E3M2", "E2M3", "E2M1"]

# CSV row key mappings
BASE_KEYS = {
    "E5M2": "dot_fp_8_52",
    "E4M3": "dot_fp_8_43",
    "E3M2": "dot_fp_6_32",
    "E2M3": "dot_fp_6_23",
    "E2M1": "dot_fp_4",
}

FP16_KEYS = {
    "E5M2": "fp16_dot_fp_8_52",
    "E4M3": "fp16_dot_fp_8_43",
    "E3M2": "fp16_dot_fp_6_32",
    "E2M3": "fp16_dot_fp_6_23",
    "E2M1": "fp16_dot_fp_4",
}

PACKED_KEYS = {
    "E5M2": "E5_M2",
    "E4M3": "E4_M3",
    "E3M2": "E3_M2",
    "E2M3": "E2_M3",
    "E2M1": "E2_M1",
}

AITB_KEYS = {
    "E5M2": "E5_M2",
    "E4M3": "E4_M3",
    "E3M2": "E3_M2",
    "E2M3": "E2_M3",
    "E2M1": "E2_M1",
}

# Depth (num_dots) per architecture
PACKED_DEPTH = {"E5M2": 3, "E4M3": 2, "E3M2": 3, "E2M3": 2, "E2M1": 4}
AITB_DEPTH = {"E5M2": None, "E4M3": None, "E3M2": None, "E2M3": 2, "E2M1": 2}


def read_csv(filename):
    """Read CSV and return dict mapping first column key to (fmax, alms, dsps)."""
    path = os.path.join(SCRIPT_DIR, filename)
    data = {}
    if not os.path.isfile(path):
        return data
    with open(path, newline="") as f:
        reader = csv.reader(f)
        next(reader)  # skip header
        for row in reader:
            if len(row) < 4:
                continue
            key = row[0].strip()
            try:
                fmax = float(row[1]) if row[1].strip() else None
                alms = int(row[2]) if row[2].strip() else None
                dsps = int(row[3]) if row[3].strip() else None
            except (ValueError, IndexError):
                continue
            data[key] = (fmax, alms, dsps)
    return data


def calc_tflops(fmax, alms, dsps, num_dots):
    """Calculate TFLOPS using the device formula."""
    if fmax is None or alms is None or num_dots is None:
        return None
    if alms == 0:
        return None

    alm_fit = math.floor(TOTAL_ALMS / alms)

    if dsps is None or dsps == 0:
        fit = alm_fit
    else:
        dsp_fit = math.floor(TOTAL_DSPS / dsps)
        fit = min(alm_fit, dsp_fit)

    NUM_OPS_PER_DOT = 2  # Each dot product counts as 2 FLOPs (1 multiply + 1 add)
    return fit * num_dots * fmax * DOT_SIZE * NUM_OPS_PER_DOT / 1_000 / 1_000


def compute_all_tflops():
    """Compute TFLOPS for all formats and implementations."""
    base_data = read_csv("base.csv")
    opt_data = read_csv("base_opt.csv")
    packed_data = read_csv("packed_base.csv")
    fp16_data = read_csv("fp16_base.csv")
    aitb_data = read_csv("aitb_base.csv")

    results = {
        "Baseline SL": [],
        "Optimized SL": [],
        "Packed DSPs": [],
        "FP16 Vector Mode": [],
        "Tensor Mode": [],
    }

    for fmt in FORMATS:
        # Baseline
        row = base_data.get(BASE_KEYS[fmt])
        if row:
            results["Baseline SL"].append(calc_tflops(*row, num_dots=1))
        else:
            results["Baseline SL"].append(None)

        # Optimized
        row = opt_data.get(BASE_KEYS[fmt])
        if row:
            results["Optimized SL"].append(calc_tflops(*row, num_dots=1))
        else:
            results["Optimized SL"].append(None)

        # Packed
        row = packed_data.get(PACKED_KEYS[fmt])
        if row:
            results["Packed DSPs"].append(calc_tflops(*row, num_dots=PACKED_DEPTH[fmt]))
        else:
            results["Packed DSPs"].append(None)

        # FP16
        row = fp16_data.get(FP16_KEYS[fmt])
        if row:
            results["FP16 Vector Mode"].append(calc_tflops(*row, num_dots=1))
        else:
            results["FP16 Vector Mode"].append(None)

        # Tensor
        row = aitb_data.get(AITB_KEYS[fmt])
        depth = AITB_DEPTH[fmt]
        if row and depth:
            results["Tensor Mode"].append(calc_tflops(*row, num_dots=depth))
        else:
            results["Tensor Mode"].append(None)

    return results


def print_table(results):
    """Print TFLOPS table in terminal matching csv_viz.sh style."""
    header_fmt = "%-6s | %-14s %-14s %-14s %-16s %-14s"
    row_fmt = "%-6s | %-14s %-14s %-14s %-16s %-14s"
    sep = "-------|" + "-" * 79

    print()
    print(header_fmt % ("Format", "Baseline SL", "Optimized SL", "Packed DSPs",
                        "FP16 Vector Mode", "Tensor Mode"))
    print(sep)

    for i, fmt in enumerate(FORMATS):
        cells = []
        for impl in ["Baseline SL", "Optimized SL", "Packed DSPs",
                     "FP16 Vector Mode", "Tensor Mode"]:
            val = results[impl][i]
            cells.append(f"{val:.2f}" if val is not None else "--")
        print(row_fmt % (fmt, *cells))

    print()


def plot_chart(results):
    """Generate grouped bar chart and save as PDF."""
    x = np.arange(len(FORMATS))
    n_bars = 5
    width = 0.15

    fig, ax = plt.subplots(figsize=(7, 3))

    colors = {
        "Baseline SL": "#FFE2FF",
        "Optimized SL": "#E66A87",
        "Packed DSPs": "#16637E",
        "FP16 Vector Mode": "#D9CFBD",
        "Tensor Mode": "#CC94E3",
    }

    for idx, (impl, color) in enumerate(colors.items()):
        vals = [v if v is not None else 0 for v in results[impl]]
        offset = (idx - n_bars / 2 + 0.5) * width
        bars = ax.bar(x + offset, vals, width, label=impl, color=color,
                      edgecolor="black", linewidth=0.7)
        # Hide bars that are None (zero-height with no edge)
        for j, v in enumerate(results[impl]):
            if v is None:
                bars[j].set_linewidth(0)
                bars[j].set_edgecolor("none")

    ax.set_xticks(x)
    ax.set_xticklabels(FORMATS)
    ax.set_ylabel("TFLOPS")
    ax.set_yticks(np.arange(0, 15, 2))
    ax.yaxis.grid(True, linestyle=":", color="lightgray")
    ax.set_axisbelow(True)

    for spine in ax.spines.values():
        spine.set_visible(True)
        spine.set_linewidth(1)

    ax.legend(loc="upper left", fontsize=8, frameon=True, edgecolor="black",
              ncol=3, columnspacing=1)

    plt.tight_layout()
    plt.savefig(os.path.join(SCRIPT_DIR, "tflops_chart_fig3.pdf"), format="pdf")
    plt.close()


if __name__ == "__main__":
    results = compute_all_tflops()
    print_table(results)
    plot_chart(results)
    print("Chart saved to tflops_chart_fig3.pdf")