#!/usr/bin/env bash

# Display characterization results in a unified table matching the paper format
# Order: E5M2, E4M3, E3M2, E2M3, E2M1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define format order and name mappings
FORMATS=("E5M2" "E4M3" "E3M2" "E2M3" "E2M1")

# Map format names to CSV row identifiers per file type
declare -A BASE_KEYS=(
	[E5M2]="dot_fp_8_52"
	[E4M3]="dot_fp_8_43"
	[E3M2]="dot_fp_6_32"
	[E2M3]="dot_fp_6_23"
	[E2M1]="dot_fp_4"
)

declare -A FP16_KEYS=(
	[E5M2]="fp16_dot_fp_8_52"
	[E4M3]="fp16_dot_fp_8_43"
	[E3M2]="fp16_dot_fp_6_32"
	[E2M3]="fp16_dot_fp_6_23"
	[E2M1]="fp16_dot_fp_4"
)

declare -A PACKED_KEYS=(
	[E5M2]="E5_M2"
	[E4M3]="E4_M3"
	[E3M2]="E3_M2"
	[E2M3]="E2_M3"
	[E2M1]="E2_M1"
)

declare -A AITB_KEYS=(
	[E5M2]="E5_M2"
	[E4M3]="E4_M3"
	[E3M2]="E3_M2"
	[E2M3]="E2_M3"
	[E2M1]="E2_M1"
)

# Depth values per architecture (from paper)
declare -A PACKED_DEPTH=(
	[E5M2]="3"
	[E4M3]="2"
	[E3M2]="3"
	[E2M3]="2"
	[E2M1]="4"
)

declare -A AITB_DEPTH=(
	[E5M2]="--"
	[E4M3]="--"
	[E3M2]="--"
	[E2M3]="2"
	[E2M1]="2"
)

# Extract a row from a CSV: extract_row <file> <key>
# Returns: Fmax,ALMs,DSPs or empty
extract_row() {
	local file="$1" key="$2"
	if [[ -f "$file" ]]; then
		grep "^${key}," "$file" | head -1 | cut -d',' -f2-
	fi
}

# Format a cell group: ALMs DSPs Freq D
format_cells() {
	local row="$1" depth="$2"
	if [[ -z "$row" ]]; then
		printf " %6s %3s %4s %2s" "--" "--" "--" "--"
	else
		local fmax alms dsps
		fmax=$(echo "$row" | cut -d',' -f1)
		alms=$(echo "$row" | cut -d',' -f2)
		dsps=$(echo "$row" | cut -d',' -f3)
		fmax=$(printf "%.0f" "$fmax")
		alms=$(printf "%'d" "$alms")
		printf " %6s %3s %4s %2s" "$alms" "$dsps" "$fmax" "$depth"
	fi
}

# Each cell group is: " %6s %3s %4s %2s" = 1+6+1+3+1+4+1+2 = 19 chars
# Print header
printf "\n"
printf "%-6s |%-19s|%-19s|%-19s|%-19s|%-19s\n" \
	"" \
	"     Baseline    " \
	"  Optimized Base " \
	"    Packed DSP   " \
	"   FP16 Vector   " \
	"   Tensor Mode   "
printf "%-6s | %6s %3s %4s %2s| %6s %3s %4s %2s| %6s %3s %4s %2s| %6s %3s %4s %2s| %6s %3s %4s %2s\n" \
	"Format" \
	"ALMs" "DSP" "Freq" "D" \
	"ALMs" "DSP" "Freq" "D" \
	"ALMs" "DSP" "Freq" "D" \
	"ALMs" "DSP" "Freq" "D" \
	"ALMs" "DSP" "Freq" "D"
printf "%s\n" "-------|-------------------|-------------------|-------------------|-------------------|-------------------"

for fmt in "${FORMATS[@]}"; do
	base_row=$(extract_row "$SCRIPT_DIR/base.csv" "${BASE_KEYS[$fmt]}")
	opt_row=$(extract_row "$SCRIPT_DIR/base_opt.csv" "${BASE_KEYS[$fmt]}")
	packed_row=$(extract_row "$SCRIPT_DIR/packed_base.csv" "${PACKED_KEYS[$fmt]}")
	fp16_row=$(extract_row "$SCRIPT_DIR/fp16_base.csv" "${FP16_KEYS[$fmt]}")
	aitb_row=$(extract_row "$SCRIPT_DIR/aitb_base.csv" "${AITB_KEYS[$fmt]}")

	base_cells=$(format_cells "$base_row" "1")
	opt_cells=$(format_cells "$opt_row" "1")
	packed_cells=$(format_cells "$packed_row" "${PACKED_DEPTH[$fmt]}")
	fp16_cells=$(format_cells "$fp16_row" "1")
	aitb_cells=$(format_cells "$aitb_row" "${AITB_DEPTH[$fmt]}")

	printf "%-6s |%s|%s|%s|%s|%s\n" \
		"$fmt" "$base_cells" "$opt_cells" "$packed_cells" "$fp16_cells" "$aitb_cells"
done

printf "\n"

