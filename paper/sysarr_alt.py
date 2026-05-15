import plotly.graph_objects as go
from plotly.subplots import make_subplots
from data import (
    RED, PURPLE, GREEN, BEIGE, formats_data,
)

FORMAT_COLORS = {
    "E2M1": RED,
    "E2M3": PURPLE,
    "E3M2": GREEN,
    "E4M3": BEIGE,
}

metrics = ["Fmax (MHz)", "Logic ALMs", "DSP Blocks"]

fig = make_subplots(rows=1, cols=3, subplot_titles=metrics, horizontal_spacing=0.1)

for fmt, old_label, old_N, old_fmax, old_alms, old_dsp, new_N, new_fmax, new_alms, new_dsp in formats_data:
    color = FORMAT_COLORS[fmt]
    old_data = [old_fmax, old_alms, old_dsp]
    new_data = [new_fmax, new_alms, new_dsp]

    for col, (od, nd) in enumerate(zip(old_data, new_data), 1):
        show_legend = col == 1
        # Old (dotted)
        fig.add_trace(go.Scatter(
            x=old_N, y=od, mode="lines+markers",
            name=fmt + " " + old_label,
            line=dict(color=color, width=2, dash="dot"),
            marker=dict(size=7, color=color, symbol="x-thin-open"),
            legendgroup=fmt + "_old", showlegend=show_legend,
        ), row=1, col=col)
        # New (solid)
        fig.add_trace(go.Scatter(
            x=new_N, y=nd, mode="lines+markers",
            name=fmt + " Proposed",
            line=dict(color=color, width=2),
            marker=dict(size=7, color=color),
            legendgroup=fmt + "_new", showlegend=show_legend,
        ), row=1, col=col)

fig.update_layout(
    width=1200, height=400,
    plot_bgcolor="white", paper_bgcolor="white",
    font=dict(size=14, color="black"),
    margin=dict(l=60, r=20, t=60, b=50),
    legend=dict(
        orientation="h", yanchor="bottom", y=1.02, xanchor="center", x=0.5,
        font=dict(size=12), bordercolor="black", borderwidth=1,
    ),
)

for col in range(1, 4):
    fig.update_xaxes(
        title_text="N", showline=True, linewidth=1, linecolor="black",
        mirror=True, ticks="outside", row=1, col=col,
    )
    fig.update_yaxes(
        showline=True, linewidth=1, linecolor="black", mirror=True,
        gridcolor="lightgray", griddash="dot", ticks="outside",
        row=1, col=col,
    )

fig.update_traces(marker_line_width=1, marker_line_color="black")
fig.write_image("sysarr_alt.pdf", format="pdf")
print("Wrote sysarr_alt.pdf")
