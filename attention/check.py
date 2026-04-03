import struct

i = 0
lines = []

def get(prefix):
    global i
    while i < len(lines):
        if lines[i].startswith(prefix):
            value = lines[i].removeprefix(prefix)
            i += 1
            return value
        i += 1


def fp32_to_bf16_rne(fp32_bits):
    """Convert 32-bit FP32 integer to 16-bit BF16 integer with RNE rounding."""
    truncated = (fp32_bits >> 16) & 0xFFFF
    round_bit = (fp32_bits >> 15) & 1
    sticky_bit = 1 if (fp32_bits & 0x7FFF) else 0
    lsb = truncated & 1
    if round_bit and (sticky_bit or lsb):
        truncated = (truncated + 1) & 0xFFFF
    return truncated


def bf16_to_float(bf16_bits):
    """Convert 16-bit BF16 integer to Python float."""
    fp32_bits = bf16_bits << 16
    return struct.unpack('>f', struct.pack('>I', fp32_bits))[0]


def bf16_to_mxfp(bf16_vec, exp_width, man_width):
    """
    Pure-Python model of conv_bf16tomxfp.
    Returns (mx_vec, mx_exp) where mx_vec is a list of element ints
    and mx_exp is the 8-bit shared exponent.
    """
    k = len(bf16_vec)
    bit_width = 1 + exp_width + man_width
    max_exp_elem = 1 << (exp_width - 1)

    # Extract sign, exp, man from BF16
    sgns = []
    exps = []
    mans = []
    for v in bf16_vec:
        sgns.append((v >> 15) & 1)
        exps.append((v >> 7) & 0xFF)
        mans.append(v & 0x7F)

    # Find E_max
    e_max_raw = max(exps)
    e_max = e_max_raw if e_max_raw >= max_exp_elem else max_exp_elem

    # Calculate shift amounts and extended mantissas
    d_shifts = []
    man_exts = []
    for idx in range(k):
        d_shifts.append(e_max - exps[idx])
        if exps[idx] != 0:
            man_exts.append((1 << 7) | mans[idx])  # {1'b1, man[6:0]}
        else:
            man_exts.append((mans[idx] << 1) & 0xFF)  # {man[6:0], 1'b0}

    # Shift and round each element (model of fp_rnd_rne with width_i=8)
    mx_vec = []
    for idx in range(k):
        elem = _fp_rnd_rne(man_exts[idx], d_shifts[idx], exp_width, man_width)
        mx_vec.append((sgns[idx] << (exp_width + man_width)) | elem)

    # Shared exponent
    sh_exp = (e_max - max_exp_elem) & 0x1FF  # 9 bits, but stored as 8
    if e_max == 0xFF:
        mx_exp = 0xFF
    else:
        mx_exp = sh_exp & 0xFF

    return mx_vec, mx_exp


def _clz8(val):
    """Count leading zeros of an 8-bit unsigned value (matches clz_int RTL)."""
    val = val & 0xFF
    count = 0
    for bit_pos in range(7, -1, -1):
        if (val >> bit_pos) & 1:
            break
        count += 1
    return count


def _fp_rnd_rne(num, shift, exp_width, man_width):
    """
    Exact Python model of fp_rnd_rne.sv with width_i=8, width_shift=8.
    Returns (exp_width + man_width) bit element (unsigned, no sign).
    """
    width_i = 8
    max_exp_elem = (1 << exp_width) - 1
    max_man_elem = (1 << man_width) - 1

    num = num & 0xFF
    shift = shift & 0xFF

    # --- CLZ and align ---
    lz = _clz8(num)
    if lz >= width_i:
        lz = width_i
    aligned = (num << lz) & ((1 << width_i) - 1)

    # --- Normal case: round mantissa ---
    # R_nrm = aligned[width_i - man_width - 2]
    r_pos_nrm = width_i - man_width - 2  # bit index for R
    R_nrm = (aligned >> r_pos_nrm) & 1

    # S_nrm = |aligned[width_i - man_width - 3 : 0]
    s_bits = r_pos_nrm  # number of bits below R
    s_mask_nrm = (1 << s_bits) - 1 if s_bits > 0 else 0
    S_nrm = 1 if (aligned & s_mask_nrm) else 0

    # p0_nrm_rnd = R_nrm && (aligned[width_i - man_width - 1] || S_nrm)
    lsb_nrm = (aligned >> (r_pos_nrm + 1)) & 1
    nrm_rnd = 1 if (R_nrm and (lsb_nrm or S_nrm)) else 0

    # p0_man_nrm_ofl = aligned[width_i-2 : width_i-man_width-1] + nrm_rnd
    # This is man_width bits from aligned[width_i-2] down to aligned[width_i-man_width-1]
    man_hi = width_i - 2
    man_lo = width_i - man_width - 1
    man_bits = (aligned >> man_lo) & ((1 << man_width) - 1)
    man_nrm_ofl = man_bits + nrm_rnd  # man_width+1 bits
    exp_nrm_ofl = (man_nrm_ofl >> man_width) & 1
    man_nrm = man_nrm_ofl & max_man_elem

    # p0_truncate = exp_nrm_ofl && (shift == 0) && (lz == 0)
    truncate = exp_nrm_ofl and (shift == 0) and (lz == 0)

    # --- Denormal case ---
    # p0_dnm_shift is width_shift+2 = 10 bits, unsigned arithmetic
    # p0_dnm_shift = $unsigned(shift) + $unsigned(lz) + $unsigned(width_i) - $unsigned(max_exp_elem) - $unsigned(man_width)
    width_dnm = 8 + 2  # width_shift + 2 = 10
    dnm_shift = (shift + lz + width_i - max_exp_elem - man_width) & ((1 << width_dnm) - 1)

    # sticky_mask = ~({(width_i-1){1'b1}} << (dnm_shift - 1))
    # The RTL uses aligned[width_i-2:0] (7 bits for width_i=8)
    aligned_lo = aligned & ((1 << (width_i - 1)) - 1)  # aligned[6:0]
    if dnm_shift >= 1 and dnm_shift <= (width_i - 1):
        sm = (1 << (width_i - 1)) - 1  # all ones, 7 bits
        sm_shifted = (sm << (dnm_shift - 1)) & ((1 << (width_i - 1)) - 1)
        sticky_mask = (~sm_shifted) & ((1 << (width_i - 1)) - 1)
    elif dnm_shift >= 1:
        sticky_mask = (1 << (width_i - 1)) - 1  # all bits sticky
    else:
        sticky_mask = 0
    S_dnm = 1 if (aligned_lo & sticky_mask) else 0

    # R_dnm and p0_dnm_rnd with conditional logic from RTL
    # RTL: $signed({1'b0, i_shift}) <= $signed($unsigned(max_exp_elem) + $unsigned(man_width) - $unsigned(lz))
    shift_signed = shift  # always positive (0-extended)
    limit_r = max_exp_elem + man_width - lz  # can be negative in Python = signed in RTL
    cond_r = (shift_signed <= limit_r)

    if cond_r and dnm_shift >= 1 and dnm_shift <= width_i:
        R_dnm = (aligned >> (dnm_shift - 1)) & 1
    else:
        R_dnm = 0

    # RTL: $signed({1'b0, i_shift}) < $signed($unsigned(max_exp_elem) + $unsigned(man_width) - $unsigned(lz))
    cond_rnd = (shift_signed < limit_r)
    if cond_rnd:
        dnm_lsb = (aligned >> dnm_shift) & 1 if 0 <= dnm_shift < width_i else 0
        dnm_rnd = 1 if (R_dnm and (dnm_lsb or S_dnm)) else 0
    else:
        dnm_rnd = 1 if (R_dnm and S_dnm) else 0

    # p0_man_dnm_shifted = aligned >> dnm_shift (man_width bits)
    man_dnm_shifted = (aligned >> dnm_shift) & max_man_elem if 0 <= dnm_shift < width_i else 0

    # p0_man_dnm_ofl = man_dnm_shifted + dnm_rnd
    man_dnm_ofl = man_dnm_shifted + dnm_rnd
    exp_dnm_ofl = (man_dnm_ofl >> man_width) & 1
    man_dnm = man_dnm_ofl & max_man_elem

    # --- Output exponent calculation ---
    # p0_exp_out = max_exp_elem + exp_nrm_ofl - shift - lz (signed arithmetic, width_shift+2 bits)
    exp_out = max_exp_elem + exp_nrm_ofl - shift - lz

    # p0_dnm_out = (max_exp_elem - lz) <= shift  (signed comparison)
    dnm_out = (max_exp_elem - lz) <= shift

    # --- Assign outputs ---
    if num != 0:
        if dnm_out:
            o_exp = exp_dnm_ofl
        elif truncate:
            o_exp = max_exp_elem
        else:
            o_exp = exp_out & ((1 << exp_width) - 1)
    else:
        o_exp = 0

    if dnm_out:
        o_man = man_dnm
    elif truncate:
        o_man = max_man_elem if num != 0 else 0
    else:
        o_man = man_nrm

    return (o_exp << man_width) | o_man


def check_fp32_to_mxfp():
    EXP_W = int(get('EXPONENT_WIDTH='))
    MAN_W = int(get('MANTISSA_WIDTH='))
    BLOCK_SIZE = int(get('BLOCK_SIZE='))
    tests = int(get('tests='))
    BIT_W = 1 + EXP_W + MAN_W

    print(f"EXPONENT_WIDTH: {EXP_W}")
    print(f"MANTISSA_WIDTH: {MAN_W}")
    print(f"BLOCK_SIZE: {BLOCK_SIZE}")
    print(f"tests: {tests}")

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))

        # Read FP32 inputs (binary strings)
        fp32_inputs = []
        for idx in range(BLOCK_SIZE):
            val_str = get(f'in[{idx}]=')
            fp32_inputs.append(int(val_str, 2))

        # Read shared block exponent
        blk_exp_str = get('out_blk_exp=')
        hw_blk_exp = int(blk_exp_str, 2)

        # Read MXFP outputs
        hw_outs = []
        for idx in range(BLOCK_SIZE):
            val_str = get(f'out[{idx}]=')
            hw_outs.append(int(val_str, 2))

        # Software model: FP32 -> BF16 (RNE) -> MXFP
        bf16_vec = [fp32_to_bf16_rne(v) for v in fp32_inputs]
        sw_mx_vec, sw_mx_exp = bf16_to_mxfp(bf16_vec, EXP_W, MAN_W)

        # Compare block exponent
        if hw_blk_exp != sw_mx_exp:
            print(f"Test {test_num} FAILED: blk_exp hw={hw_blk_exp:#04x} sw={sw_mx_exp:#04x}")
            all_passed = False

        # Compare each element
        for idx in range(BLOCK_SIZE):
            if hw_outs[idx] != sw_mx_vec[idx]:
                print(f"Test {test_num} FAILED: out[{idx}] hw={hw_outs[idx]:#0{BIT_W // 4 + 3}x} "
                      f"sw={sw_mx_vec[idx]:#0{BIT_W // 4 + 3}x} "
                      f"(fp32={fp32_inputs[idx]:#010x} bf16={bf16_vec[idx]:#06x})")
                all_passed = False

    return all_passed


def check_transpose():
    INPUT_ROWS = int(get('INPUT_ROWS='))
    INPUT_COLS = int(get('INPUT_COLS='))
    DATA_WIDTH = int(get('DATA_WIDTH='))
    tests = int(get('tests='))

    print(f"INPUT_ROWS: {INPUT_ROWS}")
    print(f"INPUT_COLS: {INPUT_COLS}")
    print(f"DATA_WIDTH: {DATA_WIDTH}")
    print(f"tests: {tests}")

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))

        in_data = []
        for row in range(INPUT_ROWS):
            row_data = []
            for col in range(INPUT_COLS):
                val = get(f'in_data[{row}][{col}]=')
                row_data.append(val)
            in_data.append(row_data)

        out_data = []
        for row in range(INPUT_COLS):
            row_data = []
            for col in range(INPUT_ROWS):
                val = get(f'out_data[{row}][{col}]=')
                row_data.append(val)
            out_data.append(row_data)

        # Verify transpose: out_data[j][i] should equal in_data[i][j]
        for row in range(INPUT_ROWS):
            for col in range(INPUT_COLS):
                expected = in_data[row][col]
                got = out_data[col][row]
                if got != expected:
                    print(f"Test {t} FAILED: out_data[{col}][{row}]={got} != in_data[{row}][{col}]={expected}")
                    all_passed = False

    return all_passed


def fp32_bits_to_float(bits):
    """Convert 32-bit integer (FP32 encoding) to Python float."""
    return struct.unpack('>f', struct.pack('>I', bits & 0xFFFFFFFF))[0]


def check_causal_mask():
    N = int(get('N='))
    tests = int(get('tests='))
    NEG_INF = 0xFF800000

    print(f"N: {N}")
    print(f"tests: {tests}")

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))

        in_data = []
        for row in range(N):
            row_data = []
            for col in range(N):
                val_str = get(f'in[{row}][{col}]=')
                row_data.append(int(val_str, 2))
            in_data.append(row_data)

        out_data = []
        for row in range(N):
            row_data = []
            for col in range(N):
                val_str = get(f'out[{row}][{col}]=')
                row_data.append(int(val_str, 2))
            out_data.append(row_data)

        for row in range(N):
            for col in range(N):
                if col > row:
                    expected = NEG_INF
                else:
                    expected = in_data[row][col]
                if out_data[row][col] != expected:
                    print(f"Test {test_num} FAILED: out[{row}][{col}]={out_data[row][col]:#010x} "
                          f"expected={expected:#010x}")
                    all_passed = False

    return all_passed


def check_softmax():
    import math
    import numpy as np
    N = int(get('N='))
    tests = int(get('tests='))

    print(f"N: {N}")
    print(f"tests: {tests}")

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))

        in_data = []
        for row in range(N):
            row_data = []
            for col in range(N):
                val_str = get(f'in[{row}][{col}]=')
                row_data.append(int(val_str, 2))
            in_data.append(row_data)

        out_data = []
        for row in range(N):
            row_data = []
            for col in range(N):
                val_str = get(f'out[{row}][{col}]=')
                row_data.append(int(val_str, 2))
            out_data.append(row_data)

        # Software reference: row-wise softmax in FP32 precision to match RTL
        for row in range(N):
            floats_in = np.array([fp32_bits_to_float(in_data[row][col]) for col in range(N)], dtype=np.float32)
            mx = np.max(floats_in)
            exps = np.exp((floats_in - mx).astype(np.float32)).astype(np.float32)
            s = np.sum(exps).astype(np.float32)
            if s == 0.0:
                sw_softmax = np.zeros(N, dtype=np.float32)
            else:
                sw_softmax = (exps / s).astype(np.float32)

            for col in range(N):
                hw_val = fp32_bits_to_float(out_data[row][col])
                sw_val = float(sw_softmax[col])
                if sw_val == 0.0:
                    if hw_val != 0.0:
                        print(f"Test {test_num} FAILED: out[{row}][{col}] hw={hw_val} sw={sw_val}")
                        all_passed = False
                else:
                    rel_err = abs(hw_val - sw_val) / abs(sw_val)
                    if rel_err > 1e-3:
                        print(f"Test {test_num} FAILED: out[{row}][{col}] hw={hw_val:.8e} sw={sw_val:.8e} "
                              f"rel_err={rel_err:.2e}")
                        all_passed = False

    return all_passed


if __name__ == "__main__":

    print("\nREADING RESULTS FROM TRANSCRIPT")

    with open("transcript") as f:
        lines = [line.removeprefix('#').strip() for line in f.readlines()]

    tag = get('!!!DUT=')
    print(f"\nDUT: {tag}")

    if tag == 'transpose':
        all_passed = check_transpose()
    elif tag == 'fp32_to_mxfp':
        all_passed = check_fp32_to_mxfp()
    elif tag == 'causal_mask':
        all_passed = check_causal_mask()
    elif tag == 'softmax':
        all_passed = check_softmax()
    else:
        print(f"Unknown tag: {tag}")
        all_passed = False

    if all_passed:
        print("\nALL TESTS PASSED\n")
    else:
        print("\nSOME TESTS FAILED\n")


