#!/usr/bin/env python3
import csv
import os
import subprocess

import plotly.graph_objects as go
from plotly.subplots import make_subplots

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

k = 32  # MX block size

RED = "#C0392B"
GREEN = "#27AE60"

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
        return f"{fmt_name} (N/A)"
    return f"{fmt_name} ({proposed_peak / baseline_peak:.1f}x higher perf.)"


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


def build_plots():
    # Layout: row1 = E5M2, E4M3, E3M2 / row2 = E2M3, E2M1, (legend)
    layout = [
        ("E5_M2", 1, 1),
        ("E4_M3", 1, 2),
        ("E3_M2", 1, 3),
        ("E2_M3", 2, 1),
        ("E2_M1", 2, 2),
    ]

    fig = make_subplots(rows=2, cols=3,
                        shared_yaxes=True, horizontal_spacing=0.02, vertical_spacing=0.15)

    first_trace = True
    annotations = []

    for fmt, row, col in layout:
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

        fig.add_trace(
            go.Scatter(x=base_N, y=base_tflops,
                       name="Baseline DSP", marker_color=RED, line=dict(color=RED),
                       legendgroup="Baseline DSP", showlegend=first_trace),
            row=row, col=col,
        )
        fig.add_trace(
            go.Scatter(x=prop_N, y=prop_tflops,
                       name="Our Proposed DSP", marker_color=GREEN, line=dict(color=GREEN),
                       legendgroup="Our Proposed DSP", showlegend=first_trace),
            row=row, col=col,
        )
        first_trace = False

        title_text = format_perf_title(LABELS[fmt], base_tflops, prop_tflops)
        xref = f"x{'' if (row == 1 and col == 1) else (row - 1) * 3 + col}"
        yref = f"y{'' if (row == 1 and col == 1) else (row - 1) * 3 + col}"
        annotations.append(
            dict(text=f"<b>{title_text}</b>", xref=xref, yref=yref,
                 x=1, y=21, showarrow=False, font=dict(size=18),
                 xanchor="left", yanchor="top")
        )

    fig.update_layout(
        width=600, height=400,
        plot_bgcolor="white", paper_bgcolor="white",
        font=dict(size=14, color="black"),
        margin=dict(l=40, r=10, t=10, b=60),
        showlegend=True,
        annotations=annotations,
    )

    fig.update_layout(
        legend=dict(
            xanchor="center", yanchor="middle",
            x=0.84, y=0.15,
            font=dict(size=15),
            bordercolor="black", borderwidth=1,
        ),
    )

    fig.update_xaxes(
        title_text="N", title_standoff=3,
        showline=True, linewidth=1, linecolor="black", mirror=True,
        ticks="outside", tickmode="array", tickvals=[0, 5, 10, 15, 20],
        tickangle=0, tickfont=dict(size=16), range=[0, 21],
        showgrid=True, gridcolor="lightgray", griddash="dot",
    )
    fig.update_yaxes(
        showline=True, linewidth=1, linecolor="black", mirror=True,
        gridcolor="lightgray", griddash="dot",
        ticks="outside", tickangle=0, range=[0, 22],
    )
    fig.update_yaxes(title_text="TFLOPS", title_standoff=2, row=1, col=1)
    fig.update_yaxes(title_text="TFLOPS", title_standoff=2, row=2, col=1)

    # Hide 6th subplot axes (used as legend area)
    fig.update_xaxes(visible=False, row=2, col=3)
    fig.update_yaxes(visible=False, row=2, col=3)

    out_path = os.path.join(SCRIPT_DIR, "tflops_sweep.pdf")
    fig.write_image(out_path, format="pdf")
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
