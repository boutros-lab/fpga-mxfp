import plotly.graph_objects as go
from plotly.subplots import make_subplots
from data import *

k = 32


def calc_tflops(N_list, D, fmax_list):
    return [n * n * D * 2 * k * f * 1e-6 for n, f in zip(N_list, fmax_list)]


def format_perf_title(fmt_name, baseline_vals, proposed_vals):
    baseline_peak = max(baseline_vals) if baseline_vals else 0
    proposed_peak = max(proposed_vals) if proposed_vals else 0
    if baseline_peak <= 0:
        return f"{fmt_name} (N/A)"
    return f"{fmt_name} ({proposed_peak / baseline_peak:.1f}x higher perf.)"


fig = make_subplots(rows=2, cols=3,
                    shared_yaxes=True, horizontal_spacing=0.02, vertical_spacing=0.15)

# E5M2: baseline D=3, proposed (DOT8) D=2
fig.add_trace(go.Scatter(x=e5m2_baseline_N, y=calc_tflops(e5m2_baseline_N, 3, e5m2_baseline_fmax),
                         name="Baseline DSP", marker_color=RED, line=dict(color=RED), legendgroup="Baseline DSP"), row=1, col=1)
fig.add_trace(go.Scatter(x=e5m2_dot8_proposed_N, y=calc_tflops(e5m2_dot8_proposed_N, 2, e5m2_dot8_proposed_fmax),
                         name="Our Proposed DSP", marker_color=GREEN, line=dict(color=GREEN), legendgroup="Our Proposed DSP"), row=1, col=1)

# E4M3: packed(baseline) D=2, proposed D=2
fig.add_trace(go.Scatter(x=e4m3_baseline_N, y=calc_tflops(e4m3_baseline_N, 2, e4m3_baseline_fmax),
                         name="Baseline", marker_color=RED, line=dict(color=RED), legendgroup="Baseline DSP", showlegend=False), row=1, col=2)
fig.add_trace(go.Scatter(x=e4m3_proposed_N, y=calc_tflops(e4m3_proposed_N, 2, e4m3_proposed_fmax),
                         name="Proposed", marker_color=GREEN, line=dict(color=GREEN), legendgroup="Our Proposed DSP", showlegend=False), row=1, col=2)

# E3M2: packed(baseline) D=3, proposed D=2
fig.add_trace(go.Scatter(x=e3m2_baseline_N, y=calc_tflops(e3m2_baseline_N, 3, e3m2_baseline_fmax),
                         name="Baseline", marker_color=RED, line=dict(color=RED), legendgroup="Baseline DSP", showlegend=False), row=1, col=3)
fig.add_trace(go.Scatter(x=e3m2_proposed_N, y=calc_tflops(e3m2_proposed_N, 2, e3m2_proposed_fmax),
                         name="Proposed", marker_color=GREEN, line=dict(color=GREEN), legendgroup="Our Proposed DSP", showlegend=False), row=1, col=3)

# E2M3: baseline D=2, proposed D=2
fig.add_trace(go.Scatter(x=e2m3_baseline_N, y=calc_tflops(e2m3_baseline_N, 2, e2m3_baseline_fmax),
                         name="Baseline", marker_color=RED, line=dict(color=RED), legendgroup="Baseline DSP", showlegend=False), row=2, col=1)
fig.add_trace(go.Scatter(x=e2m3_proposed_N, y=calc_tflops(e2m3_proposed_N, 2, e2m3_proposed_fmax),
                         name="Proposed", marker_color=GREEN, line=dict(color=GREEN), legendgroup="Our Proposed DSP", showlegend=False), row=2, col=1)

# E2M1: baseline D=2, proposed D=2
fig.add_trace(go.Scatter(x=e2m1_baseline_N, y=calc_tflops(e2m1_baseline_N, 2, e2m1_baseline_fmax),
                         name="Baseline", marker_color=RED, line=dict(color=RED), legendgroup="Baseline DSP", showlegend=False), row=2, col=2)
fig.add_trace(go.Scatter(x=e2m1_proposed_N, y=calc_tflops(e2m1_proposed_N, 2, e2m1_proposed_fmax),
                         name="Proposed", marker_color=GREEN, line=dict(color=GREEN), legendgroup="Our Proposed DSP", showlegend=False), row=2, col=2)

fig.update_layout(
    width=600, height=400,
    plot_bgcolor="white", paper_bgcolor="white",
    font=dict(size=14, color="black"),
    margin=dict(l=40, r=10, t=10, b=60),
    showlegend=True,
)

# Subplot titles inside top-left of each plot with computed speedup
titles = [
    (
        format_perf_title(
            "E5M2",
            calc_tflops(e5m2_baseline_N, 3, e5m2_baseline_fmax),
            calc_tflops(e5m2_dot8_proposed_N, 2, e5m2_dot8_proposed_fmax),
        ),
        "x", "y",
    ),
    (
        format_perf_title(
            "E4M3",
            calc_tflops(e4m3_baseline_N, 2, e4m3_baseline_fmax),
            calc_tflops(e4m3_proposed_N, 2, e4m3_proposed_fmax),
        ),
        "x2", "y2",
    ),
    (
        format_perf_title(
            "E3M2",
            calc_tflops(e3m2_baseline_N, 3, e3m2_baseline_fmax),
            calc_tflops(e3m2_proposed_N, 2, e3m2_proposed_fmax),
        ),
        "x3", "y3",
    ),
    (
        format_perf_title(
            "E2M3",
            calc_tflops(e2m3_baseline_N, 2, e2m3_baseline_fmax),
            calc_tflops(e2m3_proposed_N, 2, e2m3_proposed_fmax),
        ),
        "x4", "y4",
    ),
    (
        format_perf_title(
            "E2M1",
            calc_tflops(e2m1_baseline_N, 2, e2m1_baseline_fmax),
            calc_tflops(e2m1_proposed_N, 2, e2m1_proposed_fmax),
        ),
        "x5", "y5",
    ),
]
for title_text, xref, yref in titles:
    fig.add_annotation(text=f"<b>{title_text}</b>", xref=xref, yref=yref,
                       x=1, y=21, showarrow=False, font=dict(size=18),
                       xanchor="left", yanchor="top")

# Place legend in the 6th subplot area
fig.update_layout(
    legend=dict(
        xanchor="center", yanchor="middle",
        x=0.84, y=0.15,
        font=dict(size=15),
        bordercolor="black", borderwidth=1,
    ),
)

fig.update_xaxes(title_text="N", title_standoff=3, showline=True, linewidth=1, linecolor="black", mirror=True, ticks="outside",
                 tickmode="array", tickvals=[0, 5, 10, 15, 20], tickangle=0, tickfont=dict(size=16), range=[0, 21],
                 showgrid=True, gridcolor="lightgray", griddash="dot")
fig.update_yaxes(showline=True, linewidth=1, linecolor="black", mirror=True, gridcolor="lightgray", griddash="dot", ticks="outside", tickangle=0, range=[0, 22])
fig.update_yaxes(title_text="TFLOPS", title_standoff=2, row=1, col=1)
fig.update_yaxes(title_text="TFLOPS", title_standoff=2, row=2, col=1)

# Hide axes on the 6th subplot (must come after global axis updates)
fig.update_xaxes(visible=False, row=2, col=3)
fig.update_yaxes(visible=False, row=2, col=3)

fig.write_image("tflops.pdf", format="pdf")
