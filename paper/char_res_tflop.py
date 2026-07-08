import plotly.graph_objects as go

FIRST = "#FFFBCA"
SECOND = "#FFCA68"
THIRD = "#FF8800"
FOURTH = "#EA1010"
FIFTH = "#900000"

OFF_WHITE = "#EDEDFF"
BEIGE = "#D9CFBD"
PURPLE = "#CC94E3"
RED = "#E66A87"
LIGHT_RED = "#FFE2FF"
GREEN = "#16637E"
LIGHT_GREEN = "#97DDFF"

formats = ["E5M2", "E4M3", "E3M2", "E2M3", "E2M1"]

#Format | Baseline SL    Optimized SL   Packed DSPs    FP16 Vector Mode Tensor Mode   
#-------|-------------------------------------------------------------------------------
#E5M2   | 0.15           1.65           2.12           1.53             --            
#E4M3   | 0.23           2.31           3.35           1.51             --            
#E3M2   | 0.55           5.12           6.53           1.52             --            
#E2M3   | 0.68           5.90           5.66           1.48             12.36         
#E2M1   | 1.59           11.46          12.31          1.53             12.36         

baseline = [0.15, 0.23, 0.55, 0.68, 1.59]
optimized = [1.65, 2.31, 5.12, 5.90, 11.46]
packed = [2.12, 3.35, 6.53, 5.66, 12.31]
fp16 = [1.53, 1.51, 1.52, 1.48, 1.53]
tensor = [None, None, None, 12.36, 12.36]

fig = go.Figure()

# Baseline SL, Optimized SL, Packed DSPs, FP16 Vector Mode, Tensor Mode

# Add bars with tighter grouping
fig.add_bar(name="Baseline SL", x=formats, y=baseline, marker_color=LIGHT_RED, legendgroup="row1")
fig.add_bar(name="Optimized SL", x=formats, y=optimized, marker_color=RED, legendgroup="row1")
fig.add_bar(name="Packed DSPs", x=formats, y=packed, marker_color=GREEN, legendgroup="row1")
fig.add_bar(name="FP16 Vector Mode", x=formats, y=fp16, marker_color=BEIGE, legendgroup="row2")
fig.add_bar(name="Tensor Mode", x=formats, y=tensor, marker_color=PURPLE, legendgroup="row2")

# Layout tweaks to match paper style
fig.update_layout(
    barmode="group",
    width=700,
    height=300,
    plot_bgcolor="white",
    paper_bgcolor="white",
    font=dict(size=20, color="black"),
    margin=dict(l=80, r=20, t=20, b=40),
    legend=dict(
        orientation="h",
        yanchor="top",
        y=0.99,
        xanchor="left",
        x=0.01,
        font=dict(size=20),
        bordercolor="black",
        borderwidth=1,
        tracegroupgap=2,
        traceorder="grouped",
    ),
)

# Axis styling (important for paper look)
fig.update_xaxes(
    showline=True,
    linewidth=1,
    linecolor="black",
    mirror=True,
    ticks="outside"
)

fig.update_yaxes(
    title=dict(text="TFLOPS", standoff=2),
    showline=True,
    linewidth=1,
    linecolor="black",
    mirror=True,
    gridcolor="lightgray",
    griddash="dot",
    ticks="outside",
    dtick=2,
)

# Make bars thinner & tighter like the figure
fig.update_traces(
    marker_line_width=1,
    marker_line_color="black",
)

fig.update_layout(
    bargap=0.1,      # space between groups
    bargroupgap=0  # space within group (tight like paper)
)

#fig.show()
fig.write_image("graph.pdf", format="pdf")
