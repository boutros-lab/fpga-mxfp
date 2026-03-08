#!/usr/bin/env python3
#
# Generate data for MXFP dot product circuits
#
# Generates the following inputs:
#   vector_a.hex     - space seperated argument defined MXFP vector of length K
#   vector_b.hex     - space seperated argument defined MXFP vector of length K
#   shared_exp_a.hex - shared exponent/scale for vector a
#   shared_exp_b.hex - shared exponent/scale for vector b
#
# Generates the following outputs:
#   fixed_result.hex - fixed point representation of dot product result, shared exponent not taken into account
#   fp32_result.hex  - fp32 representation of dot product result, shared exponent taken into account
#
# Usage:
#   Example generating data for E3M2, vector length 32, 64 tests:
#     ./generate_data.py -e 3 -m 2 -k 32 -t 64
#
#     Use -n to disable subnormal generation
#     Use -i to disable shared exponent (file will still be generated, shared exponents will be equal to bias)
#     Use --no_infnan to disable Inf/NaN generation (for MXFP8 E5M2)
#     Use -s with -i to self-check generated data with FP32 operations, this is expected to fail for larger formats

import os
import sys
import random
import math
import struct
import argparse

# Create a random MXFP number
def generate_mxfp(exp_bits, man_bits, no_subnormals=False, no_infnan=False):
    max_exp = (1 << exp_bits) - 1

    while True:
        mxfp = random.getrandbits(1 + exp_bits + man_bits)
        exp = (mxfp >> man_bits) & ((1 << exp_bits) - 1)

        if ((exp != 0) or (no_subnormals == False)) and ((exp < max_exp) or (no_infnan == False)):
            break

    return mxfp

# Create a random shared exponent
def generate_shared_exponent(exp_bits, return_bias=False):
    if return_bias:
        # Return exponent bias, has no effect on final value
        return (2 ** (exp_bits - 1)) - 1

    return random.getrandbits(exp_bits)

# Create a k length vector of MXFP numbers
def generate_mxfp_vector(exp_bits, man_bits, k, no_subnormals=False, no_infnan=False):
    vector = []

    for i in range(k):
        vector.append(generate_mxfp(exp_bits, man_bits, no_subnormals, no_infnan))

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

    mask = (1 << mult_bits) - 1
    
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

# Round to nearest even, return updated man and exp
def round_to_even(man, exp, man_bits, trunc, trunc_bits):
    msb = (trunc >> (trunc_bits - 1)) & 0x1

    if (msb == 1):
        # >= 0.5
        max_man = (1 << man_bits) - 1

        lsb_mask = (1 << (trunc_bits - 1)) -1
        lsb = trunc & lsb_mask

        if (lsb == 0):
            # Exactly 0.5
            # Round to nearest even
            man_lsb = man & 0x1

            if (man_lsb == 1):
                man += 1
        else:
            # > 0.5
            man += 1

        if (man > max_man):
            # Mantissa overflow
            man  = 0
            exp += 1

        return man, exp

    else:
        # < 0.5
        return man, exp

# Convert fixed point representation to FP32
def fixed_to_fp32(num, bits, point_position, shared_exp_a, shared_exp_b, rne=True):
    # FP32 Components:
    exp_bits  = 8
    man_bits  = 23
    fp32_bias = 2**(exp_bits-1) - 1

    sign = (num >> (bits - 1)) & 1

    if num == 0:
        return 0, 0.0

    # two's complement function provides result as bits + 1
    # We want to maintain the number of bits, provide bits - 1
    num = get_twos_complement(sign, num, (bits - 1))

    # TODO, check
    # magnitude is representable in (fixed_bits - 1), extra bit for sign
    # mult_bits multiplies fixed_bits by 2, adds the extra bit for the sign again, this extra bit is unneeded
    # sum_bits just adds log2(k) to mult_bits
    # so the magnitude should be representable in (sum_bits - 2)
    # this is what will ultimately be in the mantissa and implied 1
    # so, maximum sum_bits for 0-error FP32 is 26 (23 man, 1 implied = 24, + 2 = 26)
    assert (num < (1 << (bits - 2))), "ERROR: Number exceeds expected bounds."

    # Bit position of leading 1
    leading_1_pos = math.floor(math.log2(num))

    # Check for rounding in large numbers, 
    # math.log2() result may be rounded, leading to incorrect 
    # leading_1_pos, and a 2x larger number than expected
    if (2 ** leading_1_pos > num):
        # 2 ** leading_1_pos should always be <= num
        # If it's greater, rounding occured, correct leading_1_pos
        leading_1_pos -= 1

    exp = fp32_bias

    exp += leading_1_pos - point_position

    exp += shared_exp_a + shared_exp_b - (2 * fp32_bias)

    if (exp >= 2**exp_bits):
        # Overflow
        exp = 2**exp_bits - 1 # exp all 1's for inf/nan
        num = 0 # sets man, 0 for inf, !=0 for nan
    elif exp < 0:
        # Underflow
        fp32_bits = sign << (exp_bits + man_bits)
        fp32      = struct.unpack('>f', struct.pack('>I', fp32_bits))[0]

        return fp32_bits, fp32

    man_mask = (1 << leading_1_pos) - 1

    # Remove leading 1
    man = num & man_mask

    if man_bits > leading_1_pos:
        man = man << (man_bits - leading_1_pos)
    elif man_bits < leading_1_pos:
        # More than 24 bits represented
        man_shift   = leading_1_pos - man_bits
        man_shifted = man >> man_shift

        # Round to nearest even
        # If disabled, will round to zero
        if (rne):
            trunc_mask = (1 << man_shift) - 1
            trunc      = man & trunc_mask

            man_shifted, exp = round_to_even(man_shifted, exp, man_bits, trunc, man_shift)

            if (exp >= 2**exp_bits):
                # Overflow
                exp         = 2**exp_bits - 1 # exp all 1's for inf/nan
                man_shifted = 0 # sets man, 0 for inf, !=0 for nan

        man = man_shifted

    fp32_bits = (sign << (man_bits + exp_bits)) + (exp << man_bits) + man

    fp32 = struct.unpack('>f', struct.pack('>I', fp32_bits))[0]

    return fp32_bits, fp32

# Self check generated data vs FP32 operations
# FP32 is inexact, so this is expected to mismatch for some
# MXFP formats, does not take shared exponents into account
def self_check(vector_a_list, vector_b_list, fp32_result_list, exp_bits, man_bits, bias, tolerance=0.0):
    import numpy as np

    max_error = 0.0
    
    for a_vec, b_vec, fp32_orig in zip(vector_a_list, vector_b_list, fp32_result_list):
        # Use numpy for explicit FP32 operations
        fp32_a      = np.zeros((1,1), dtype='float32')
        fp32_b      = np.zeros((1,1), dtype='float32')
        fp32_python = np.zeros((1,1), dtype='float32')
    
        for a, b in zip(a_vec, b_vec):
            fp32_a    = mxfp_to_fp32(a, exp_bits, man_bits, bias)
            fp32_b    = mxfp_to_fp32(b, exp_bits, man_bits, bias)
            fp32_python += fp32_a * fp32_b

        if (fp32_python != fp32_orig):
            error = abs((fp32_orig - fp32_python[0][0]) / fp32_orig) * 100
    
            if (error > tolerance):
                print("ERROR: Mismatch!")
                print(f"fp32_python: {fp32_python[0][0]:f}")
                print(f"fp32_orig:   {fp32_orig:f}")
    
                print(f"Error: {error:f}%")
    
                for vec in [a_vec, b_vec]:
                    print ("IN VEC: ", end="")
                    for el in vec:
                        print (f"{el:x} ", end="")
                    print("")
    
                sys.exit(1)
    
            max_error = max(error, max_error)
    
    print(f"Error Tolerance: {tolerance:f}%")
    print(f"Max FP32 Error:  {max_error:f}%")

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
    parser = argparse.ArgumentParser(description='Generate MXFP Dot Product Data')
    parser.add_argument('-e', '--exp_bits', type=int, default=2, help="MXFP exponent bits, default: 2")
    parser.add_argument('-m', '--man_bits', type=int, default=1, help="MXFP mantissa bits, default: 1")
    parser.add_argument('-k', '--vector_length', type=int, default=32, help="Length of input vectors/dot product, default: 32")
    parser.add_argument('-t', '--test_length', type=int, default=256, help="Number of test cases, default: 256")
    parser.add_argument('-i', '--ignore_shared_exp', action='store_true', help="Ignore generated shared exponents in FP32 results")
    parser.add_argument('-n', '--no_subnormals', action='store_true', help="Do not generate subnormals in input vectors")
    parser.add_argument('--no_infnan', action='store_true', help="Do not generate Inf/NaN inputs, applicable to MXFP8 E5M2")
    parser.add_argument('-s', '--self_check', action='store_true', help="Self check against FP32 operaions, used only with ignore_shared_exp")

    args = parser.parse_args()

    if (args.self_check and not args.ignore_shared_exp):
        parser.error("Illegal Arguments: Cannot enable -s/--self_check without -i/--ignore_shared_exp")

    # TODO: extend this for scale/shared_exp
    # Only E5M2 supports Inf and NaN encodings
    if ((args.exp_bits != 5) and args.no_infnan):
        parser.error("Illegal Arguments: No Inf/NaN set for MX format without Inf/NaN encoding")

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
    if exp_bits != 0:
        emin = 2**(exp_bits-1) - 2
        point_position = emin + man_bits
    else:
        # MXINT8 has implicit scale of 2^-6
        emin = 0
        point_position = 0 #6 TODO

    mult_point_position = point_position * 2

    # Get exponent bias
    if exp_bits != 0:
        bias = 2**(exp_bits-1) - 1
    else:
        # MXINT8
        bias = 0

    print("MXFP Format Details:")
    print(f"\tS: 1b,  E: {exp_bits}b,  M: {man_bits}b")
    print(f"\tExponent Bias: {bias},  Emin: -{emin}")
    print(f"\tMXFP fixed point length: {fixed_bits}b, fraction bits: {point_position}b")
    print(f"\tFixed point mult length: {mult_bits}b, fraction bits: {mult_point_position}b")
    print(f"\tFixed point result length: {sum_bits}b, fraction bits: {mult_point_position}b")

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

    fixed_result_list     = []
    fp32_bits_result_list = []
    fp32_result_list      = []

    # Generate input vectors
    for i in range(test_length):
        vector_a_list.append(generate_mxfp_vector(exp_bits, man_bits, k, args.no_subnormals, args.no_infnan))
        vector_b_list.append(generate_mxfp_vector(exp_bits, man_bits, k, args.no_subnormals, args.no_infnan))

        shared_exp_a_list.append(generate_shared_exponent(shared_exp_bits, args.ignore_shared_exp))
        shared_exp_b_list.append(generate_shared_exponent(shared_exp_bits, args.ignore_shared_exp))

    # Find Fixed-point dot product results
    for vector_a, vector_b in zip(vector_a_list, vector_b_list):
        fixed_result_list.append(dot_mxfp(vector_a, vector_b, exp_bits, man_bits, mult_bits, sum_bits))

    # Convert fixed-point results to fp32 and apply shared exponents
    for fixed_result, shared_exp_a, shared_exp_b in zip(fixed_result_list, shared_exp_a_list, shared_exp_b_list):
        fp32_bits, fp32 = fixed_to_fp32(fixed_result, sum_bits, mult_point_position, shared_exp_a, shared_exp_b)

        fp32_result_list.append(fp32)
        fp32_bits_result_list.append(fp32_bits)

    print("Generated Data Details:")
    print(f"\tGenerated {test_length} {k} length E{exp_bits}M{man_bits} Input Vectors\n\t{sum_bits}b Fixed-Point Results, and FP32 Results")
    print(f"\tOutput Directory: {OUTPUT_ROOT}")

    # MUST be used with -i/--ignore_shared_exp
    if args.self_check:
        tolerance = 0.0

        if (exp_bits > 3):
            # Formats with E > 3 show noticeable error
            # TODO, can we derive a tolerance based on format and k?
            tolerance = 0.1

        self_check(vector_a_list, vector_b_list, fp32_result_list, exp_bits, man_bits, bias, tolerance)

    # Write to output files
    write_vector_list_to_file(vector_a_list, shared_exp_a_list, vector_a_file, shared_exp_a_file)
    write_vector_list_to_file(vector_b_list, shared_exp_b_list, vector_b_file, shared_exp_b_file)

    write_result_list_to_file(fixed_result_list, fixed_result_file)
    write_result_list_to_file(fp32_bits_result_list, fp32_result_file)


if __name__ == '__main__':
    main()
