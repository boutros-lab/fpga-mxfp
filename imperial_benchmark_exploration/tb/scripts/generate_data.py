#!/usr/bin/env python3

import random
import math

# Create a random MXFP number
def generate_mxfp(exp_bits, man_bits):
    return random.getrandbits(1 + exp_bits + man_bits)

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
    twos_complement = (num ^ mask) + 1

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

    # Convert to two's complement
    man_res = get_twos_complement(sign_res, man_res, mult_bits)

    return man_res

def dot_mxfp():
    return 0

# Convert fixed point representation to FP32
def fixed_to_fp32(num, bits, shared_exp):
    # Convert from two's complement
    # Count Leading 0's
    # Get Exponent
    # Add Shared Exponent
    # Get Mantissa
    # Pack bits
    # Convert bin to fp32 (struct)
    return 0

def main():
    import argparse

    parser = argparse.ArgumentParser(description='Generate MXFP Dot Product Data')
    parser.add_argument('-e', '--exp_bits', type=int, default=2)
    parser.add_argument('-m', '--man_bits', type=int, default=1)
    parser.add_argument('-k', '--vector_length', type=int, default=8)

    args = parser.parse_args()

    exp_bits = args.exp_bits
    man_bits = args.man_bits
    k        = args.vector_length

    # Get widths of intermediate representations
    fixed_bits = 2**exp_bits + man_bits
    mult_bits  = 2 * fixed_bits
    sum_bits   = mult_bits + math.ceil(math.log2(k))

    # Get exponent bias
    bias = 2**(exp_bits-1) - 1

    test_mxfp  = generate_mxfp(exp_bits, man_bits)
    test_mxfp1 = generate_mxfp(exp_bits, man_bits)

    test_fixed  = mxfp_to_fixed(test_mxfp, exp_bits, man_bits)
    test_fixed1 = mxfp_to_fixed(test_mxfp1, exp_bits, man_bits)

    test_mult = mult_mxfp(test_mxfp, test_mxfp1, exp_bits, man_bits, mult_bits)

    print(f"Original Number 0: 0b{test_mxfp:04b}")
    print(f"Fixed Point     0: 0b{test_fixed:0{fixed_bits}b}")
    print(f"Original Number 1: 0b{test_mxfp1:04b}")
    print(f"Fixed Point     1: 0b{test_fixed1:0{fixed_bits}b}")
    print(f"Mult             : 0b{test_mult:0{mult_bits}b}")


if __name__ == '__main__':
    main()
