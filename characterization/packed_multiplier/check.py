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

def check_packed_dot_product():
    mantissa_width = int(get('mantissa_width='))
    exponent_width = int(get('exponent_width='))
    num_ops = int(get('num_ops='))
    block_size = int(get('block_size='))
    tests = int(get('tests='))

    print(f"mantissa_width: {mantissa_width}")
    print(f"exponent_width: {exponent_width}")
    print(f"num_ops: {num_ops}")
    print(f"block_size: {block_size}")
    print(f"tests: {tests}")

    bias = (2 ** exponent_width) // 2 - 1
    print(f"bias: {bias}")

    def mxfp_to_float(mxfp_str):
        sign = int(mxfp_str[0])
        exponent_bits = int(mxfp_str[1:1+exponent_width], 2)
        if exponent_bits == 0:
            exponent = 1 - bias
            mantissa = int('0' + mxfp_str[1+exponent_width:], 2) / (2 ** mantissa_width)
        else:
            exponent = exponent_bits - bias
            mantissa = int('1' + mxfp_str[1+exponent_width:], 2) / (2 ** mantissa_width)
        if sign == 1:
            mantissa = -mantissa
        value = mantissa * (2 ** exponent)
        return value

    def fixed_to_float(fixed_str):
        width = len(fixed_str)
        value = int(fixed_str, 2)
        if value >= (1 << (width - 1)):
            value -= (1 << width)
        return value / (2 ** (2 * bias + 2 * mantissa_width))

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))

        shared_operands = []
        operands = []
        for j in range(block_size):
            shared_operands.append(get(f'sharedOperand[{j}]='))
            operands_row = []
            for k in range(num_ops):
                operands_row.append(get(f'operand[{j}][{k}]='))
            operands.append(operands_row)
        results = []
        for j in range(num_ops):
            results.append(get(f'result[{j}]='))

        shared_operands = [mxfp_to_float(so) for so in shared_operands]
        operands = [[mxfp_to_float(operand) for operand in row] for row in operands]
        results = [fixed_to_float(res) for res in results]

        # Compute expected results
        expected_results = []
        for op_idx in range(num_ops):
            acc = 0.0
            for block_idx in range(block_size):
                a = operands[block_idx][op_idx]
                b = shared_operands[block_idx]
                acc += a * b
            expected_results.append(acc)

        # Compare results
        tolerance = 0.1
        for i in range(num_ops):
            diff = abs(results[i] - expected_results[i])
            if diff <= tolerance:
                #print(f"Test {t} Result {i} PASSED: got {results[i]}, expected {expected_results[i]}, diff {diff}")
                pass
            else:
                print(f"Test {t} Result {i} FAILED: got {results[i]}, expected {expected_results[i]}, diff {diff}")
                all_passed = False
    return all_passed

def check_packed_multiplier():
    op_width = int(get('op_width='))
    num_ops = int(get('num_ops='))
    tests = int(get('tests='))

    print(f"op_width: {op_width}")
    print(f"num_ops: {num_ops}")
    print(f"tests: {tests}")

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))
        shared_a = int(get('sharedOperand_a='), 2)
        shared_b = int(get('sharedOperand_b='), 2)
        ops_a = []
        ops_b = []
        for j in range(num_ops):
            ops_a.append(int(get(f'operand_a[{j}]='), 2))
            ops_b.append(int(get(f'operand_b[{j}]='), 2))
        prods_a = []
        prods_b = []
        for j in range(num_ops):
            prods_a.append(int(get(f'product_a[{j}]='), 2))
            prods_b.append(int(get(f'product_b[{j}]='), 2))
        for j in range(num_ops):
            expected_a = ops_a[j] * shared_a
            expected_b = ops_b[j] * shared_b
            if prods_a[j] != expected_a:
                print(f"Test {t} FAILED: operand_a[{j}]={ops_a[j]} * sharedOperand_a={shared_a} = expected {expected_a}, got {prods_a[j]}")
                all_passed = False
            if prods_b[j] != expected_b:
                print(f"Test {t} FAILED: operand_b[{j}]={ops_b[j]} * sharedOperand_b={shared_b} = expected {expected_b}, got {prods_b[j]}")
                all_passed = False
    return all_passed

def check_dsp_2x18x18():
    tests = int(get('tests='))

    print(f"tests: {tests}")

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))
        ax = int(get('ax='), 2)
        ay = int(get('ay='), 2)
        bx = int(get('bx='), 2)
        by = int(get('by='), 2)
        resulta = int(get('resulta='), 2)
        resultb = int(get('resultb='), 2)

        expected_a = ax * ay
        expected_b = bx * by
        if resulta != expected_a:
            print(f"Test {t}a FAILED: ax={ax} * ay={ay} = expected {expected_a}, got {resulta}")
            all_passed = False
        if resultb != expected_b:
            print(f"Test {t}b FAILED: bx={bx} * by={by} = expected {expected_b}, got {resultb}")
            all_passed = False
    return all_passed

def check_packed_dot_product_fp32():
    mantissa_width = int(get('mantissa_width='))
    exponent_width = int(get('exponent_width='))
    num_ops = int(get('num_ops='))
    block_size = int(get('block_size='))
    tests = int(get('tests='))

    print(f"mantissa_width: {mantissa_width}")
    print(f"exponent_width: {exponent_width}")
    print(f"num_ops: {num_ops}")
    print(f"block_size: {block_size}")
    print(f"tests: {tests}")

    bias = (2 ** exponent_width) // 2 - 1
    print(f"bias: {bias}")

    def mxfp_to_float(mxfp_str):
        sign = int(mxfp_str[0])
        exponent_bits = int(mxfp_str[1:1+exponent_width], 2)
        if exponent_bits == 0:
            exponent = 1 - bias
            mantissa = int('0' + mxfp_str[1+exponent_width:], 2) / (2 ** mantissa_width)
        else:
            exponent = exponent_bits - bias
            mantissa = int('1' + mxfp_str[1+exponent_width:], 2) / (2 ** mantissa_width)
        if sign == 1:
            mantissa = -mantissa
        value = mantissa * (2 ** exponent)
        return value

    def fp32_to_float(bits_str):
        import struct
        value = int(bits_str, 2)
        return struct.unpack('!f', struct.pack('!I', value))[0]

    all_passed = True
    for t in range(tests):
        test_num = int(get('test='))
        sharedBlock_exponent = int(get('sharedBlock_exponent='), 2)
        block_exponents = []
        for j in range(num_ops):
            block_exponents.append(int(get(f'block_exponent[{j}]='), 2))

        shared_operands = []
        operands = []
        for j in range(block_size):
            shared_operands.append(get(f'sharedOperand[{j}]='))
            operands_row = []
            for k in range(num_ops):
                operands_row.append(get(f'operand[{j}][{k}]='))
            operands.append(operands_row)
        results = []
        for j in range(num_ops):
            results.append(get(f'result[{j}]='))

        shared_operands = [mxfp_to_float(so) for so in shared_operands]
        operands = [[mxfp_to_float(operand) for operand in row] for row in operands]
        results = [fp32_to_float(res) for res in results]

        # Compute expected results
        expected_results = []
        for op_idx in range(num_ops):
            scale = 2.0 ** (block_exponents[op_idx] + sharedBlock_exponent - 127 - 127)
            acc = 0.0
            for block_idx in range(block_size):
                a = operands[block_idx][op_idx]
                b = shared_operands[block_idx]
                acc += a * b
            expected_results.append(acc * scale)

        # Compare results
        import math
        tolerance = 0.01
        for i in range(num_ops):
            expected = expected_results[i]
            got = results[i]
            # Both infinity with same sign is a pass
            if math.isinf(got) and math.isinf(expected) and math.copysign(1, got) == math.copysign(1, expected):
                #print(f"Test {test_num} Result {i} PASSED: got {got}, expected {expected} (both infinity)")
                pass
            # Hardware saturates to infinity when expected overflows
            elif math.isinf(got) and not math.isinf(expected) and abs(expected) > 3.4e38:
                #print(f"Test {test_num} Result {i} PASSED: got {got}, expected {expected} (hardware saturation to infinity)")
                pass
            # Hardware underflows to zero when combined exponent <= 0
            elif got == 0.0 and abs(expected) < 1.18e-38:
                #print(f"Test {test_num} Result {i} PASSED: got {got}, expected {expected} (hardware underflow to zero)")
                pass
            elif expected == 0.0:
                rel_diff = abs(got)
                if rel_diff > tolerance:
                    print(f"Test {test_num} Result {i} FAILED: got {got}, expected {expected}, rel_diff {rel_diff}")
                    all_passed = False
                else:
                    #print(f"Test {test_num} Result {i} PASSED: got {got}, expected {expected}, rel_diff {rel_diff}")
                    pass
            else:
                rel_diff = abs(got - expected) / abs(expected)
                if rel_diff >= tolerance:
                    print(f"Test {test_num} Result {i} FAILED: got {got}, expected {expected}, rel_diff {rel_diff}")
                    all_passed = False
                else: 
                    #print(f"Test {test_num} Result {i} PASSED: got {got}, expected {expected}, rel_diff {rel_diff}")
                    pass
    return all_passed


if __name__ == "__main__":

    print("\nREADING RESULTS FROM TRANSCRIPT")

    with open("transcript") as f:
        lines = [line.removeprefix('#').strip() for line in f.readlines()]

    tag = get('!!!DUT=')
    print(f"\nDUT: {tag}")

    if tag == 'packed_dot_product':
        all_passed = check_packed_dot_product()
    elif tag == 'packed_dot_product_fp32':
        all_passed = check_packed_dot_product_fp32()
    elif tag == 'packed_multiplier':
        all_passed = check_packed_multiplier()
    elif tag == 'DSP_2x18x18':
        all_passed = check_dsp_2x18x18()
    else:
        print(f"Unknown tag: {tag}")
        all_passed = False

    if all_passed:
        print("\nALL TESTS PASSED\n")
    else:
        print("\nSOME TESTS FAILED\n")