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


def fp32_bits_to_float(bits):
    """Convert 32-bit integer (FP32 encoding) to Python float."""
    return struct.unpack('>f', struct.pack('>I', bits & 0xFFFFFFFF))[0]


def mxfp_elem_to_float(elem_bits, shared_exp, exp_width, man_width):
    """Convert an MXFP element + shared block exponent back to a Python float.

    Reconstruction:
      - Effective BF16 exponent = shared_exp + elem_exp (normal) or shared_exp + 1 (subnormal)
      - Value = (-1)^sign * 2^(eff_exp - 127) * significand
    """
    sign = (elem_bits >> (exp_width + man_width)) & 1
    elem_exp = (elem_bits >> man_width) & ((1 << exp_width) - 1)
    elem_man = elem_bits & ((1 << man_width) - 1)

    if elem_exp == 0 and elem_man == 0:
        return -0.0 if sign else 0.0

    if shared_exp == 0xFF:
        return float('nan')

    elem_bias = (1 << (exp_width - 1)) - 1  # e.g. 7 for E4M3

    if elem_exp > 0:  # normal element
        eff_exp = (shared_exp - 127) + (elem_exp - elem_bias)
        significand = 1.0 + elem_man / (1 << man_width)
    else:  # subnormal element (elem_exp == 0, elem_man != 0)
        eff_exp = (shared_exp - 127) + (1 - elem_bias)
        significand = elem_man / (1 << man_width)

    value = (2.0 ** eff_exp) * significand
    return -value if sign else value


if __name__ == "__main__":
    with open("transcript") as f:
        lines = [line.removeprefix('#').strip() for line in f.readlines()]

    tag = get('!!!DUT=')
    assert tag == 'fp32_to_mxfp', f"Expected DUT=fp32_to_mxfp, got {tag}"

    EXP_W = int(get('EXPONENT_WIDTH='))
    MAN_W = int(get('MANTISSA_WIDTH='))
    BLOCK_SIZE = int(get('BLOCK_SIZE='))
    tests = int(get('tests='))
    BIT_W = 1 + EXP_W + MAN_W

    print(f"EXP_W={EXP_W}  MAN_W={MAN_W}  BLOCK_SIZE={BLOCK_SIZE}  tests={tests}\n")

    for t in range(tests):
        test_num = int(get('test='))

        fp32_inputs = []
        for idx in range(BLOCK_SIZE):
            val_str = get(f'in[{idx}]=')
            fp32_inputs.append(int(val_str, 2))

        blk_exp = int(get('out_blk_exp='), 2)

        hw_outs = []
        for idx in range(BLOCK_SIZE):
            val_str = get(f'out[{idx}]=')
            hw_outs.append(int(val_str, 2))

        # Convert to Python floats
        fp32_floats = [fp32_bits_to_float(b) for b in fp32_inputs]
        mxfp_floats = [mxfp_elem_to_float(e, blk_exp, EXP_W, MAN_W) for e in hw_outs]

        print(f"--- test {test_num} ---")
        print(f"  shared block exponent = {blk_exp}  (scale = 2^{blk_exp - 127} = {2.0 ** (blk_exp - 127):.6e})")
        print(f"  {'idx':>4s}  {'fp32':>15s}  {'mxfp':>15s}")
        for idx in range(BLOCK_SIZE):
            print(f"  {idx:4d}  {fp32_floats[idx]:>15.6e}  {mxfp_floats[idx]:>15.6e}")
        print()
