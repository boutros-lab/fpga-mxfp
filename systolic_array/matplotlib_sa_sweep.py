#!/usr/bin/env python3
import csv
import os
import subprocess

import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

# Use Liberation Sans (same font plotly used originally) to match the target style.
plt.rcParams["font.family"] = "Liberation Sans"
plt.rcParams["font.sans-serif"] = ["Liberation Sans", "Arial", "DejaVu Sans"]

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

k = 32  # MX block size

PINK = "#E08896"
TEAL = "#2E5C7E"

# Best baseline for E2M1 and E2M3: AITB mode.
AITB_CONFIGS = ["E2_M1", "E2_M3"]
# Best baseline for E3M2, E4M3, E5M2: packed multiplier.
PACKED_CONFIGS = ["E3_M2", "E4_M3", "E5_M2"]
# Proposed AITB for all modes.
AITB_PROP_CONFIGS = ["E2_M1", "E2_M3", "E3_M2", "E4_M3", "E5_M2"]

# D (num dots) per config type / format
D_AITB = 2
D_AITB_PROP = 2
D_PACKED = {"E3_M2": 3, "E4_M3": 2, "E5_M2": 3}

LABELS = {
    "E2_M1": "E2M1",
    "E2_M3": "E2M3",
    "E3_M2": "E3M2",
    "E4_M3": "E4M3",
    "E5_M2": "E5M2",
}


def calc_tflops(N_list, D, fmax_list):
    return [n * n * D * 2 * k * f * 1e-6 for n, f in zip(N_list, fmax_list)]


def parse_sweep_csv(path):
    """Return (N_list, fmax_list) sorted by N."""
    rows = []
    with open(path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append((int(row["N"]), float(row["Fmax_MHz"])))
    rows.sort(key=lambda x: x[0])
    N_list = [r[0] for r in rows]
    fmax_list = [r[1] for r in rows]
    return N_list, fmax_list


def format_perf_title(fmt_name, baseline_vals, proposed_vals):
    baseline_peak = max(baseline_vals) if baseline_vals else 0
    proposed_peak = max(proposed_vals) if proposed_vals else 0
    if baseline_peak <= 0:
        return f"{fmt_name}\nN/A"
    return f"{fmt_name}\n{proposed_peak / baseline_peak:.1f}x perf."


def check_sweep_csvs():
    missing = {"aitb": [], "packed": [], "aitb_prop": []}

    for cfg in AITB_CONFIGS:
        path = os.path.join(SCRIPT_DIR, f"{cfg}_aitb_sweep.csv")
        if not os.path.exists(path):
            missing["aitb"].append(path)

    for cfg in PACKED_CONFIGS:
        path = os.path.join(SCRIPT_DIR, f"{cfg}_packed_sweep.csv")
        if not os.path.exists(path):
            missing["packed"].append(path)

    for cfg in AITB_PROP_CONFIGS:
        path = os.path.join(SCRIPT_DIR, f"{cfg}_aitb_prop_sweep.csv")
        if not os.path.exists(path):
            missing["aitb_prop"].append(path)

    for sweep_type, paths in missing.items():
        if paths:
            print(f"Missing {sweep_type} CSVs:")
            for p in paths:
                print(f"  {p}")

    return (
        len(missing["aitb"]) == 0,
        len(missing["packed"]) == 0,
        len(missing["aitb_prop"]) == 0,
    )


def style_axis(ax):
    ax.set_xlim(0, 21)
    ax.set_ylim(0, 22)
    ax.set_xticks([0, 5, 10, 15, 20])
    ax.tick_params(axis="both", direction="out", labelsize=14)
    ax.tick_params(axis="x", labelsize=16)
    ax.grid(True, which="major", linestyle=":", color="lightgray", linewidth=0.8)
    ax.set_axisbelow(True)
    for spine in ax.spines.values():
        spine.set_color("black")
        spine.set_linewidth(1)


def build_plots():
    # Layout: row1 = E5M2, E4M3, E3M2 / row2 = E2M3, E2M1, (legend)
    layout = [
        ("E5_M2", 0, 0),
        ("E4_M3", 0, 1),
        ("E3_M2", 0, 2),
        ("E2_M3", 1, 0),
        ("E2_M1", 1, 1),
    ]

    fig, axes = plt.subplots(
        nrows=2, ncols=3, figsize=(8, 5.3),
        sharey=True, gridspec_kw=dict(hspace=0.35, wspace=0.08),
    )

    used_axes = set()

    for fmt, row, col in layout:
        ax = axes[row][col]
        used_axes.add((row, col))

        prop_path = os.path.join(SCRIPT_DIR, f"{fmt}_aitb_prop_sweep.csv")
        prop_N, prop_fmax = parse_sweep_csv(prop_path)
        prop_tflops = calc_tflops(prop_N, D_AITB_PROP, prop_fmax)

        if fmt in AITB_CONFIGS:
            base_path = os.path.join(SCRIPT_DIR, f"{fmt}_aitb_sweep.csv")
            base_D = D_AITB
        else:
            base_path = os.path.join(SCRIPT_DIR, f"{fmt}_packed_sweep.csv")
            base_D = D_PACKED[fmt]

        base_N, base_fmax = parse_sweep_csv(base_path)
        base_tflops = calc_tflops(base_N, base_D, base_fmax)

        ax.plot(base_N, base_tflops, color=PINK, marker="o", markersize=5,
                linewidth=2, label="Baseline DSP")
        ax.plot(prop_N, prop_tflops, color=TEAL, marker="o", markersize=5,
                linewidth=2, label="Our Proposed DSP")

        style_axis(ax)

        title_text = format_perf_title(LABELS[fmt], base_tflops, prop_tflops)
        ax.text(0.05, 0.90, title_text, transform=ax.transAxes,
                fontsize=18, fontweight="bold",
                ha="left", va="top", multialignment="center")

        ax.set_xlabel("N", fontsize=14, labelpad=2)
        if col == 0:
            ax.set_ylabel("TFLOPS", fontsize=14, labelpad=2)

    # Use 6th subplot area for legend
    legend_ax = axes[1][2]
    legend_ax.axis("off")
    legend_handles = [
        Line2D([0], [0], color=PINK, marker="o", markersize=6, linewidth=2,
               label="Baseline DSP"),
        Line2D([0], [0], color=TEAL, marker="o", markersize=6, linewidth=2,
               label="Our Proposed DSP"),
    ]
    legend_ax.legend(handles=legend_handles, loc="center", fontsize=15,
                     frameon=True, edgecolor="black", fancybox=False)

    fig.subplots_adjust(left=0.07, right=0.99, top=0.98, bottom=0.10)

    out_path = os.path.join(SCRIPT_DIR, "sa_tflops_sweep.pdf")
    fig.savefig(out_path, format="pdf", bbox_inches="tight")
    plt.close(fig)
    print(f"Saved: {out_path}")


def main():
    aitb_ok, packed_ok, aitb_prop_ok = check_sweep_csvs()

    scripts = []
    if not aitb_ok:
        scripts.append("run_sweep_aitb.sh")
    if not packed_ok:
        scripts.append("run_sweep_packed.sh")
    if not aitb_prop_ok:
        scripts.append("run_sweep_prop.sh")

    if scripts:
        print(f"Launching in parallel: {', '.join(scripts)}")
        procs = [subprocess.Popen(["bash", s], cwd=SCRIPT_DIR) for s in scripts]
        for s, p in zip(scripts, procs):
            rc = p.wait()
            if rc != 0:
                raise RuntimeError(f"{s} exited with code {rc}")

    build_plots()


if __name__ == "__main__":
    main()