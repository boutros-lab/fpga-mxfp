import plotly.graph_objects as go
from plotly.subplots import make_subplots
from data import (
    RED, GREEN, formats_data,
)

metrics = ["Fmax (MHz)", "Logic ALMs", "DSP Blocks"]

for fmt, old_label, old_N, old_fmax, old_alms, old_dsp, new_N, new_fmax, new_alms, new_dsp in formats_data:
    fig = make_subplots(rows=1, cols=3, subplot_titles=metrics, horizontal_spacing=0.1)

    old_data = [old_fmax, old_alms, old_dsp]
    new_data = [new_fmax, new_alms, new_dsp]

    for col, (od, nd) in enumerate(zip(old_data, new_data), 1):
        show_legend = col == 1
        fig.add_trace(go.Scatter(
            x=old_N, y=od, mode="lines+markers", name=old_label,
            line=dict(color=RED, width=2), marker=dict(size=8, color=RED),
            legendgroup="old", showlegend=show_legend,
        ), row=1, col=col)
        fig.add_trace(go.Scatter(
            x=new_N, y=nd, mode="lines+markers", name="Proposed",
            line=dict(color=GREEN, width=2), marker=dict(size=8, color=GREEN),
            legendgroup="new", showlegend=show_legend,
        ), row=1, col=col)

    fig.update_layout(
        width=1200, height=350,
        plot_bgcolor="white", paper_bgcolor="white",
        font=dict(size=14, color="black"),
        margin=dict(l=60, r=20, t=50, b=50),
        legend=dict(
            orientation="h", yanchor="bottom", y=1.02, xanchor="center", x=0.5,
            font=dict(size=14), bordercolor="black", borderwidth=1,
        ),
        title=dict(text=fmt, x=0.5, font=dict(size=18)),
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
    fig.write_image(f"sysarr_{fmt.lower()}.pdf", format="pdf")
    print(f"Wrote sysarr_{fmt.lower()}.pdf")
