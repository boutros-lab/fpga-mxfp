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


if __name__ == "__main__":

    print("\nREADING RESULTS FROM TRANSCRIPT")

    with open("transcript") as f:
        lines = [line.removeprefix('#').strip() for line in f.readlines()]

    tag = get('!!!DUT=')
    print(f"\nDUT: {tag}")

    if tag == 'transpose':
        all_passed = check_transpose()
    else:
        print(f"Unknown tag: {tag}")
        all_passed = False

    if all_passed:
        print("\nALL TESTS PASSED\n")
    else:
        print("\nSOME TESTS FAILED\n")


