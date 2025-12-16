print("")
print("CHECKING RESULTS FROM TRANSCRIPT")

with open("transcript") as f:
    lines = f.readlines()
lines = [line.removeprefix('#').strip() for line in lines]

i = 0
while '!!!START!!!' not in lines[i]:
    i += 1
i += 1  # Skip the '!!!START!!!' line
mantissa_width = int(lines[i].removeprefix('mantissa_width='))
i += 1
exponent_width = int(lines[i].removeprefix('exponent_width='))
i += 1
num_ops = int(lines[i].removeprefix('num_ops='))
i += 1  
block_size = int(lines[i].removeprefix('block_size='))
i += 1
shared_operands = []
operands = []
for j in range(block_size):
    shared_operands.append(lines[i].removeprefix(f'sharedOperand[{j}]='))
    i += 1
    operands_row = []
    for k in range(num_ops):
        operands_row.append(lines[i].removeprefix(f'operand[{j}][{k}]='))
        i += 1
    operands.append(operands_row)
results = []
for j in range(num_ops):
    results.append(lines[i].removeprefix(f'result[{j}]='))
    i += 1

bias = (2 ** exponent_width) // 2 - 1

print("")
print(f"mantissa_width: {mantissa_width}")
print(f"exponent_width: {exponent_width}")
print(f"num_ops: {num_ops}")
print(f"block_size: {block_size}")
print(f"bias: {bias}")
print("shared_operands", shared_operands)
print("operands", operands)
print("results", results)

def mxfp_to_float(mxfp_str):
    #MXFP-8 E4M3
    #SEEEEMMM
    #print("mxfp_str:", mxfp_str)
    sign = int(mxfp_str[0])
    #print("sign:", sign)
    #print("exponent bits:", mxfp_str[1:1+exponent_width])
    exponent = int(mxfp_str[1:1+exponent_width], 2) - bias
    #print("exponent:", exponent)
    #print("mantissa bits:", mxfp_str[1+exponent_width:])
    mantissa = int('1' + mxfp_str[1+exponent_width:], 2) / (2 ** mantissa_width)
    #print("mantissa:", mantissa)
    if sign == 1:
        mantissa = -mantissa
    value = mantissa * (2 ** (exponent))
    return value

shared_operands = [mxfp_to_float(so) for so in shared_operands]
operands = [[mxfp_to_float(operand) for operand in row] for row in operands]

def fixed_to_float(fixed_str):
    # fixed point is 1 sign bit, X int bits, 2*bias frac bits
    total_width = len(fixed_str)
    int_width = total_width - (2 * bias) - 1
    sign = int(fixed_str[0])
    int_part = int(fixed_str[1:1+int_width], 2)
    frac_part = int(fixed_str[1+int_width:], 2) / (2 ** (2 * bias))
    value = int_part + frac_part
    if sign == 1:
        value = -value
    return value

results = [fixed_to_float(res) for res in results]

print("")
print("shared_operands (float)", shared_operands)
print("operands (float)", operands)
print("results (float)", results)

# Compute expected results
expected_results = []
for op_idx in range(num_ops):
    acc = 0.0
    for block_idx in range(block_size):
        a = operands[block_idx][op_idx]
        b = shared_operands[block_idx]
        acc += a * b
    expected_results.append(acc)

print("")
print("expected_results (float)", expected_results)

# Compare results
tolerance = 0.1
all_passed = True
for i in range(num_ops):
    diff = abs(results[i] - expected_results[i])
    if diff <= tolerance:
        print(f"Result {i} PASSED: got {results[i]}, expected {expected_results[i]}, diff {diff}")
    else:
        print(f"Result {i} FAILED: got {results[i]}, expected {expected_results[i]}, diff {diff}")
        all_passed = False