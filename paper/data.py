# Prof's colour scheme
OFF_WHITE = "#EDEDFF"
BEIGE = "#D9CFBD"
PURPLE = "#CC94E3"
RED = "#E66A87"
LIGHT_RED = "#FFE2FF"
GREEN = "#16637E"
LIGHT_GREEN = "#97DDFF"

# E2M1 -- PROPOSED DSP
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	457.67	501	8
# 4	457.67	2012	32
# 6	457.67	4532	72
# 7	457.67	6166	98
# 10	457.67	12575	200
# 14	457.67	24735	392
# 16	457.67	32211	512
# 20	404.04	50240	800

# E2M3 -- PROPOSED DSP
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	457.67	864	12
# 4	457.67	3489	48
# 6	457.67	7820	108
# 7	457.67	10664	147
# 10	457.67	21728	300
# 14	454.13	42650	588
# 16	392.16	55655	768

# E3M2 -- PROPOSED DSP
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	457.67	864	12
# 4	457.67	3489	48
# 6	457.67	7820	108
# 7	457.67	10664	147
# 10	457.67	21728	300
# 14	454.13	42650	588
# 16	392.16	55655	768

# E4M3 -- PROPOSED DSP
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	457.67	1438	16
# 4	457.67	5777	64
# 6	457.67	13010	144
# 7	457.67	17665	196
# 10	457.67	36081	400
# 14	392.62	70644	784

# E5M2 -- PROPOSED DSP DOT8
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	457.67	1438	16
# 4	457.67	5777	64
# 6	457.67	13010	144
# 7	457.67	17665	196
# 10	457.67	36081	400
# 14	392.62	70644	784

# E5M2 -- PROPOSED DSP DOT4
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	457.67	2511	32
# 4	457.67	10057	128
# 6	457.67	22622	288
# 7	400.64	30803	392
# 9	429.18	50881	648

# E2M1 -- Baseline DSP
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	457.67	1153	16
# 4	457.67	4941	64
# 6	457.67	10651	144
# 7	457.67	14079	196
# 10	457.67	28659	400
# 14	341.76	56091	784

# E2M3 -- Baseline DSP
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	440.53	2507	16
# 4	409	10046	64
# 6	419.99	22585	144
# 7	404.2	30773	196
# 10	412.03	62565	400
# 14	379.65	122658	784

# E3M2 -- Packed
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	213.31	18739	64
# 4	202.68	75123	256
# 6	204.37	156802	576

# E4M3 -- Packed
# N	Fmax_MHz	Logic ALMs	DSP_blocks
# 2	218.96	19939	64
# 4	214.96	79902	256
# 6	202.96	182551	576


# --- E2M1 ---
e2m1_baseline_N     = [2, 4, 6, 7, 10, 14]
e2m1_baseline_fmax  = [457.67, 457.67, 457.67, 457.67, 457.67, 341.76]
e2m1_baseline_alms  = [1153, 4941, 10651, 14079, 28659, 56091]
e2m1_baseline_dsp   = [16, 64, 144, 196, 400, 784]

e2m1_proposed_N     = [2, 4, 6, 7, 10, 14, 16, 20]
e2m1_proposed_fmax  = [457.67, 457.67, 457.67, 457.67, 457.67, 457.67, 457.67, 404.04]
e2m1_proposed_alms  = [501, 2012, 4532, 6166, 12575, 24735, 32211, 50240]
e2m1_proposed_dsp   = [8, 32, 72, 98, 200, 392, 512, 800]

# --- E2M3 ---
e2m3_baseline_N     = [2, 4, 6, 7, 10, 14]
e2m3_baseline_fmax  = [440.53, 409, 419.99, 404.2, 412.03, 379.65]
e2m3_baseline_alms  = [2507, 10046, 22585, 30773, 62565, 122658]
e2m3_baseline_dsp   = [16, 64, 144, 196, 400, 784]

e2m3_proposed_N     = [2, 4, 6, 7, 10, 14, 16]
e2m3_proposed_fmax  = [457.67, 457.67, 457.67, 457.67, 457.67, 454.13, 392.16]
e2m3_proposed_alms  = [864, 3489, 7820, 10664, 21728, 42650, 55655]
e2m3_proposed_dsp   = [12, 48, 108, 147, 300, 588, 768]

# --- E3M2 ---
e3m2_baseline_N     = [2, 4, 6]
e3m2_baseline_fmax  = [213.31, 202.68, 204.37]
e3m2_baseline_alms  = [18739, 75123, 156802]
e3m2_baseline_dsp   = [64, 256, 576]

e3m2_proposed_N     = [2, 4, 6, 7, 10, 14, 16]
e3m2_proposed_fmax  = [457.67, 457.67, 457.67, 457.67, 457.67, 454.13, 392.16]
e3m2_proposed_alms  = [864, 3489, 7820, 10664, 21728, 42650, 55655]
e3m2_proposed_dsp   = [12, 48, 108, 147, 300, 588, 768]

# --- E4M3 ---
e4m3_baseline_N     = [2, 4, 6]
e4m3_baseline_fmax  = [218.96, 214.96, 202.96]
e4m3_baseline_alms  = [19939, 79902, 182551]
e4m3_baseline_dsp   = [64, 256, 576]

e4m3_proposed_N     = [2, 4, 6, 7, 10, 14]
e4m3_proposed_fmax  = [457.67, 457.67, 457.67, 457.67, 457.67, 392.62]
e4m3_proposed_alms  = [1438, 5777, 13010, 17665, 36081, 70644]
e4m3_proposed_dsp   = [16, 64, 144, 196, 400, 784]

# --- E5M2 Baseline ---
e5m2_baseline_N     = [2, 4]
e5m2_baseline_fmax  = [212.45, 210.04]
e5m2_baseline_alms  = [41704, 167149]
e5m2_baseline_dsp   = [64, 256]

# --- E5M2 DOT8 ---
e5m2_dot8_proposed_N     = [2, 4, 6, 7, 10, 14]
e5m2_dot8_proposed_fmax  = [457.67, 457.67, 457.67, 457.67, 457.67, 392.62]
e5m2_dot8_proposed_alms  = [1438, 5777, 13010, 17665, 36081, 70644]
e5m2_dot8_proposed_dsp   = [16, 64, 144, 196, 400, 784]

# --- E5M2 DOT4 ---
e5m2_dot4_proposed_N     = [2, 4, 6, 7, 9]
e5m2_dot4_proposed_fmax  = [457.67, 457.67, 457.67, 400.64, 429.18]
e5m2_dot4_proposed_alms  = [2511, 10057, 22622, 30803, 50881]
e5m2_dot4_proposed_dsp   = [32, 128, 288, 392, 648]

# Structured format list: (format_name, old_label, old_N, old_fmax, old_alms, old_dsp, new_N, new_fmax, new_alms, new_dsp)
formats_data = [
    ("E2M1", "Baseline",
     e2m1_baseline_N, e2m1_baseline_fmax, e2m1_baseline_alms, e2m1_baseline_dsp,
     e2m1_proposed_N, e2m1_proposed_fmax, e2m1_proposed_alms, e2m1_proposed_dsp),
    ("E2M3", "Baseline",
     e2m3_baseline_N, e2m3_baseline_fmax, e2m3_baseline_alms, e2m3_baseline_dsp,
     e2m3_proposed_N, e2m3_proposed_fmax, e2m3_proposed_alms, e2m3_proposed_dsp),
    ("E3M2", "Packed",
     e3m2_baseline_N, e3m2_baseline_fmax, e3m2_baseline_alms, e3m2_baseline_dsp,
     e3m2_proposed_N, e3m2_proposed_fmax, e3m2_proposed_alms, e3m2_proposed_dsp),
    ("E4M3", "Packed",
     e4m3_baseline_N, e4m3_baseline_fmax, e4m3_baseline_alms, e4m3_baseline_dsp,
     e4m3_proposed_N, e4m3_proposed_fmax, e4m3_proposed_alms, e4m3_proposed_dsp),
]
