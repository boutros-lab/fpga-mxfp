#!/usr/bin/env python3
#
# Generate data for MXFP dot product circuits
#
# Generates the following inputs vectors:
#   vector_a.hex - space seperated argument defined MXFP vector of length K, final value is an 8-bit shared exponent
#   vector_b.hex - space seperated argument defined MXFP vector of length K, final value is an 8-bit shared exponent
#
# Generates the following output vectors:
#   fixed_result.hex  - fixed point representation of dot product result, shared exponent not taken into account
#   fp32_result.hex - fp32 representation of dot product result, shared exponent taken into account
#
# Usage:
#   Example generating data for E3M2, vector length 32, 64 tests:
#     ./generate_data.py -e 3 -m 2 -k 32 -t 64
#
#     Use -n to disable subnormal generation
#     Use -i to disable shared exponent (file will still be generated but will not reflect in fp32 result)

import os
import random
import math
import struct

# Create a random MXFP number
def generate_mxfp(exp_bits, man_bits, no_subnormals=False):
    while True:
        mxfp = random.getrandbits(1 + exp_bits + man_bits)
        exp = (mxfp >> man_bits) & ((1 << exp_bits) - 1)

        if (exp != 0) or (no_subnormals == False):
            break

    return mxfp

# Create a random shared exponent
def generate_shared_exponent(exp_bits):
    return random.getrandbits(exp_bits)

# Create a k length vector of MXFP numbers
def generate_mxfp_vector(exp_bits, man_bits, k, no_subnormals=False):
    vector = []

    for i in range(k):
        vector.append(generate_mxfp(exp_bits, man_bits, no_subnormals))

    return vector

# Convert number to two's complement
def get_twos_complement(sign, num, bits):
    # If positive, return num
    if (sign == 0):
        return num

    # Expected that bits represents the number of 
    # bits in the current number, the two's complement 
    # version will need an extra bit
    mask = (1 << (bits + 1)) - 1

    # Flip bits, add 1
    twos_complement = ((num ^ mask) + 1) & mask

    return twos_complement

# Separate components of an MXFP number
def get_components(num, exp_bits, man_bits):
    # Separate components
    sign = (num >> (exp_bits + man_bits)) & 1
    exp  = (num >> man_bits) & ((1 << exp_bits) - 1)
    man  = num & ((1 << man_bits) - 1)

    if exp != 0: # Normal number
        man = man + (1 << man_bits) # Implied 1

    return sign, exp, man

# Same as separate components, but shift mantissa
def get_components_shift(num, exp_bits, man_bits):
    sign, exp, man = get_components(num, exp_bits, man_bits)

    if exp != 0: # Normal number
        man = man << (exp - 1) # Shift by exponent

    return sign, exp, man

# Convert an MXFP number to fp32
def mxfp_to_fp32(num, exp_bits, man_bits, bias):
    sign, exp, man = get_components(num, exp_bits, man_bits)

    man_mask = (1 << man_bits) - 1
    exp_c    = 0

    if exp != 0:
        # Normal number
        man = man & man_mask # remove implied 1
    elif man == 0:
        # Zero
        return 0
    else:
        # Subnormal number
        # Get position of leading 1 in mantissa
        leading_1_pos = math.floor(math.log2(man))

        # Shift mantissa left until leading 1 is removed
        man_shift = man_bits - leading_1_pos
        man = (man << man_shift) & man_mask

        # Adjust exponent to correct for mantissa shift
        exp_c = man_shift - 1

    fp32_bias = 2**(8-1) - 1

    exp = exp + fp32_bias - bias - exp_c # shift exponent to new bias

    fp32_bits = (sign << 31) + (exp << 23) + (man << (23 - man_bits))

    fp32 = struct.unpack('>f', struct.pack('>I', fp32_bits))[0]

    return fp32

# Convert an MXFP number to a fixed point representation
def mxfp_to_fixed(num, exp_bits, man_bits):
    sign, exp, man = get_components_shift(num, exp_bits, man_bits)

    # Concatenate shifted mantissa and sign bit
    num = man + (sign << (2**exp_bits + man_bits - 1))

    return num

# Multiply two MXFP numbers, return fixed point representation
def mult_mxfp(num0, num1, exp_bits, man_bits, mult_bits):
    sign0, exp0, man0 = get_components(num0, exp_bits, man_bits)
    sign1, exp1, man1 = get_components(num1, exp_bits, man_bits)

    man_res  = man0 * man1
    exp_res  = exp0 + exp1
    sign_res = sign0 ^ sign1

    # Shift by exponent
    man_res = man_res << (exp_res - (exp0 != 0) - (exp1 != 0))

    # Return early to avoid generating -0
    if man_res == 0:
        return man_res

    # Convert to two's complement
    man_res = get_twos_complement(sign_res, man_res, mult_bits - 1)

    mask = (1 << mult_bits + 1) - 1
    
    assert (man_res & mask) == man_res, "ERROR: mult_mxfp, multiplication result exceeds mult_bits."

    return man_res

# Sign extend two's complement number
def sign_extend(num, orig_bits, target_bits):
    msb = num >> (orig_bits - 1) & 1

    if msb == 0:
        return num
    
    bit_difference = target_bits - orig_bits

    extension = ((msb << bit_difference) - 1) << orig_bits

    return extension + num

# Find dot product for 2 fixed point vectors
def dot_mxfp(vector_a, vector_b, exp_bits, man_bits, mult_bits, sum_bits):
    result = 0

    mask = (1 << sum_bits) - 1

    for a, b in zip(vector_a, vector_b):
        a_mult_b = mult_mxfp(a, b, exp_bits, man_bits, mult_bits)

        # Sign extend to sum_bits
        result += sign_extend(a_mult_b, mult_bits, sum_bits)
        result &= mask

    return result

# Convert fixed point representation to FP32
def fixed_to_fp32(num, bits, point_position, shared_exp_a, shared_exp_b):
    # FP32 Components:
    exp_bits  = 8
    man_bits  = 23
    fp32_bias = 2**(exp_bits-1) - 1

    sign = (num >> (bits - 1)) & 1

    if sign == 1:
        # two's complement function provides result as bit + 1
        # We want to maintain the number of bits
        num = get_twos_complement(sign, num, (bits - 1))

    if num == 0:
        return 0, 0.0

    # Bit position of leading 1
    leading_1_pos = math.floor(math.log2(num))

    exp = fp32_bias

    exp += leading_1_pos - point_position

    # TODO, assuming this uses fp32 bias
    # TODO, handle inf/nan/etc.
    exp += shared_exp_a + shared_exp_b - (2 * fp32_bias)

    if (exp >= 2**exp_bits):
        # Overflow
        exp = 2**exp_bits - 1 # exp all 1's for inf/nan
        num = 0 # sets man, 0 for inf, !=0 for nan
    elif exp < 0:
        # Underflow
        return 0, 0.0

    man_mask = (1 << leading_1_pos) - 1

    # Remove leading 1
    man = num & man_mask

    if man_bits > leading_1_pos:
        man = man << (man_bits - leading_1_pos)
    else:
        # More than 24 bits represented
        # TODO, check, also may need to consider rounding
        man = man >> (leading_1_pos - man_bits)

    fp32_bits = (sign << (man_bits + exp_bits)) + (exp << man_bits) + man

    fp32 = struct.unpack('>f', struct.pack('>I', fp32_bits))[0]

    return fp32_bits, fp32

# Write input vector to hex file
def write_vector_list_to_file(vector_list, shared_exp_list, vector_file, shared_exp_file):
    with open(vector_file, 'w') as f:
        for vector in vector_list:
            for element in vector:
                f.write(f'{element:x} ')

            f.write(f'\n')

    with open(shared_exp_file, 'w') as f:
        for shared_exp in shared_exp_list:
            f.write(f'{shared_exp:x}\n')

# Write result to hex file
def write_result_list_to_file(result_list, file):
    with open(file, 'w') as f:
        for result in result_list:
            f.write(f'{result:x}\n')

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Generate MXFP Dot Product Data')
    parser.add_argument('-e', '--exp_bits', type=int, default=2)
    parser.add_argument('-m', '--man_bits', type=int, default=1)
    parser.add_argument('-k', '--vector_length', type=int, default=8)
    parser.add_argument('-t', '--test_length', type=int, default=256)
    parser.add_argument('-i', '--ignore_shared_exp', action='store_true')
    parser.add_argument('-n', '--no_subnormals', action='store_true')

    args = parser.parse_args()

    exp_bits        = args.exp_bits
    man_bits        = args.man_bits
    k               = args.vector_length
    shared_exp_bits = 8

    test_length = args.test_length

    # Get widths of intermediate representations
    fixed_bits = 2**exp_bits + man_bits # width of fixed point representation of MXFP number
    mult_bits  = 2 * fixed_bits # width of fixed point multiplication result
    sum_bits   = mult_bits + math.ceil(math.log2(k)) # sum of products

    # Position of the point in fixed point representations
    emin = 2**(exp_bits-1) - 2
    point_position = emin + man_bits
    mult_point_position = point_position * 2

    # Get exponent bias
    bias = 2**(exp_bits-1) - 1

    # Set output paths
    PROJ_ROOT = os.environ['PROJ_ROOT']

    OUTPUT_ROOT = PROJ_ROOT + "/data/"
    
    os.makedirs(OUTPUT_ROOT, exist_ok=True)

    vector_a_file     = OUTPUT_ROOT + "vector_a.hex"
    shared_exp_a_file = OUTPUT_ROOT + "shared_exp_a.hex"
    vector_b_file     = OUTPUT_ROOT + "vector_b.hex"
    shared_exp_b_file = OUTPUT_ROOT + "shared_exp_b.hex"
    fixed_result_file = OUTPUT_ROOT + "fixed_result.hex"
    fp32_result_file  = OUTPUT_ROOT + "fp32_result.hex"

    vector_a_list     = []
    shared_exp_a_list = []
    vector_b_list     = []
    shared_exp_b_list = []

    fixed_result_list = []
    fp32_result_list  = []

    # Generate input vectors
    for i in range(test_length):
        vector_a_list.append(generate_mxfp_vector(exp_bits, man_bits, k, args.no_subnormals))
        vector_b_list.append(generate_mxfp_vector(exp_bits, man_bits, k, args.no_subnormals))

        shared_exp_a_list.append(generate_shared_exponent(shared_exp_bits))
        shared_exp_b_list.append(generate_shared_exponent(shared_exp_bits))

    # Find Fixed-point dot product results
    for vector_a, vector_b in zip(vector_a_list, vector_b_list):
        fixed_result_list.append(dot_mxfp(vector_a, vector_b, exp_bits, man_bits, mult_bits, sum_bits))

    # Convert fixed-point results to fp32 and apply shared exponents
    for fixed_result, shared_exp_a, shared_exp_b in zip(fixed_result_list, shared_exp_a_list, shared_exp_b_list):
        if args.ignore_shared_exp:
            # Set shared exponent to fp32 bias value, effectively 0
            fp32_bits, fp32 = fixed_to_fp32(fixed_result, sum_bits, mult_point_position, 127, 127)
        else:
            fp32_bits, fp32 = fixed_to_fp32(fixed_result, sum_bits, mult_point_position, shared_exp_a, shared_exp_b)

        fp32_result_list.append(fp32_bits)

    # Write to output files
    write_vector_list_to_file(vector_a_list, shared_exp_a_list, vector_a_file, shared_exp_a_file)
    write_vector_list_to_file(vector_b_list, shared_exp_b_list, vector_b_file, shared_exp_b_file)

    write_result_list_to_file(fixed_result_list, fixed_result_file)
    write_result_list_to_file(fp32_result_list, fp32_result_file)


if __name__ == '__main__':
    main()
