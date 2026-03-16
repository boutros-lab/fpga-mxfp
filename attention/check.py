
FORMAT = "E5M2"
# Options
# MXFP-8 E5M2 SEEEEEMM
# MXFP-8 E4M3 SEEEEMMM
# MXFP-6 E3M2 SEEEMM

# Generate W_Q, W_K, W_V, W_O, X in MXFP format

def generate_mxfp_array(width, height):
    # Generate a random array of the specified width and height
    # Each element is a dict with sign, mantissa, exponent
    # Each a string bits representing the MXFP format

    # Convert the array to MXFP format (E5M2)
    mxfp_array = []
    for i in range(height):
        mxfp_row = []
        for j in range(width):
            if FORMAT == "E5M2":
                mxfp_row.append({
                    "sign": "0",
                    'exponent': "00000",
                    'mantissa': "00",
                })
            elif FORMAT == "E4M3":
                mxfp_row.append({
                    "sign": "0",
                    'exponent': "0000",
                    'mantissa': "000",
                })
            elif FORMAT == "E3M2":
                mxfp_row.append({
                    "sign": "0",
                    'exponent': "000",
                    'mantissa': "00",
                })
            else:
                raise ValueError("Unsupported format")
        mxfp_array.append(mxfp_row)
    
    return mxfp_array

print(generate_mxfp_array(4, 4))