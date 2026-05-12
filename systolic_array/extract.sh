
#!/usr/bin/env bash

N=$1
REV=$2
IMPL=$3 #{aitb|packed}

# Determine the directory pattern to search for based on DUT and M
# Using POSIX 'test' command '[ ... ]' for maximum compatibility
PATTERN="output_files_${IMPL}_${REV}"

OUT_FILE="results/${IMPL}_${REV}.csv"

echo "$PATTERN"

# echo "M,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs" > "$OUT_FILE"
echo "N,Fmax_MHz,ALMs_used_total,ALMs_LUT_FF,ALMs_LUT_only,ALMs_FF_only,ALMs_Memory,ALMs_VIRTUAL_IO,ALUT_route_through,Total_LABs,Memory_LABs,Hyper_REG,M20K_RAMs,DSP_blocks" > "$OUT_FILE"

# Use 'find' to robustly locate all matching directories and pipe the results to a loop
find ./build_24_2 -type d -name "$PATTERN" | while read d; do

#  # Initialize variables to capture report file paths
#  SYN=""
#  STA=""
#  FIT=""
#
#  # Find the report files. Use standard globbing and pick the first one found (lexicographically).
#
#  # SYN report
#  for file in "$d"/*.syn.rpt; do
#    if [ -f "$file" ]; then
#      SYN="$file"
#      break
#    fi
#  done
#
#  # STA report
#  for file in "$d"/*.sta.rpt; do
#    if [ -f "$file" ]; then
#      STA="$file"
#      break
#    fi
#  done
#
#  # FIT report
#  for file in "$d"/*.fit.place.rpt; do
#    if [ -f "$file" ]; then
#      FIT="$file"
#      break
#    fi
#  done
  SYN="build_24_2/${PATTERN}/${IMPL}_${REV}.syn.rpt"
  STA="build_24_2/${PATTERN}/${IMPL}_${REV}.sta.rpt"
  FIT="build_24_2/${PATTERN}/${IMPL}_${REV}.fit.rpt"

  # If any critical report file is missing, skip this directory.
  # Use POSIX test for checking if variable is empty (-z).
  if [ -z "$SYN" ] || [ -z "$STA" ] || [ -z "$FIT" ]; then
    echo "Warning: Missing report files in $d. Skipping."
    continue
  fi

  # Primary logic: Extract M from the directory name (e.g., output_files_rca_pipe_M128).
  # grep -oP (Perl-style regex) is used to lookbehind for _M and capture digits.
#  M_VAL=$(basename "$d" | grep -oP '(?<=_M)\d+' 2>/dev/null)

  # If M couldn't be extracted from the directory name (check if M_VAL is empty),
  # use the input parameter M.
#  if [ -z "$M_VAL" ]; then
#      M_VAL="$M"
#  fi
   
   M_VAL="$N"

  # Extract FMAX from the STA report
  FMAX=$(awk -F';' 'BEGIN{IGNORECASE=1} /fmax summary/{f=1;next} f && NF>3 && $4~/clk/{gsub(/[^0-9.]/,"",$3); print $3; exit}' "$STA" 2>/dev/null)

  # Extract ALM metrics from the FIT report
  ALM_TOTAL=$(awk -F';' 'BEGIN{IGNORECASE=1} /alms needed \[=a-b\+c\]/{gsub(/[^0-9]/,"",$3); print $3; exit}' "$FIT" 2>/dev/null)
  ALM_LUT_FF=$(awk -F';' 'BEGIN{IGNORECASE=1} /\[a\] ALMs used for LUT logic and register/{gsub(/[^0-9]/,"",$3); print $3; exit}' "$FIT" 2>/dev/null)
  ALM_LUT_ONLY=$(awk -F';' 'BEGIN{IGNORECASE=1} /\[b\] ALMs used for LUT logic/{gsub(/[^0-9]/,"",$3); print $3; exit}' "$FIT" 2>/dev/null)
  ALM_FF_ONLY=$(awk -F';' '/\[c\] ALMs used for register/{gsub(/[^0-9]/,"",$3); print $3; exit}' "$FIT" 2>/dev/null)
  ALM_MEM=$(awk -F';' '/\[d\] ALMs used for memory/{gsub(/[^0-9]/,"",$3); print $3; exit}' "$FIT" 2>/dev/null)
  ALM_VIRTUAL_IO=$(awk -F';' 'BEGIN{IGNORECASE=1} /\[d\] Due to virtual I\/O/{gsub(/[^0-9]/,"",$3); print $3; exit}' "$FIT" 2>/dev/null)
  ALUT_ROUTE=$(awk -F';' 'BEGIN{IGNORECASE=1} /Combinational ALUT usage for route-through/{gsub(/[^0-9]/,"",$3); print $3; exit}' "$FIT" 2>/dev/null)

  LAB_TOTAL=$(
    awk -F';' 'BEGIN{IGNORECASE=1} \
      /Total LABs:  partially or completely used/{
        split($3, a, "/");
        gsub(/[^0-9]/, "", a[1]);
        print a[1];
        exit
      }' "$FIT" 2>/dev/null
  )

  # Memory LABs (up to half of total LABs) ; 620 ; ;
  MEM_LABS=$(
    awk -F';' 'BEGIN{IGNORECASE=1} \
      /Memory LABs \(up to half of total LABs\)/{
        gsub(/[^0-9]/,"",$3);
        print $3;
        exit
      }' "$FIT" 2>/dev/null
  )

  # Total MLAB memory bits ; 257,584 ; ;
  MLAB_BITS=$(
    awk -F';' 'BEGIN{IGNORECASE=1} \
      /Total MLAB memory bits/{
        gsub(/[^0-9]/,"",$3);
        print $3;
        exit
      }' "$FIT" 2>/dev/null
  )

  # M20K RAMs    ; 620 ; ;
  M20K_RAMS=$(
    awk -F';' 'BEGIN{IGNORECASE=1} \
      /M20K blocks  /{
        split($3, a, "/");
        gsub(/[^0-9]/, "", a[1]);
        print a[1];
        exit
      }' "$FIT" 2>/dev/null
  )

  HYPER_REG=$(
    awk -F';' 'BEGIN{IGNORECASE=1} \
      /Hyper-Registers/{
        gsub(/[^0-9]/,"",$3);
        print $3;
        exit
      }' "$FIT" 2>/dev/null
  )

  DSP_BLOCKS=$(
  awk -F';' 'BEGIN{IGNORECASE=1}
    /DSP blocks/{
      split($3,a,"/");
      gsub(/[^0-9]/,"",a[1]);
      print a[1];
      exit
    }' "$FIT" 2>/dev/null
)

  # Append the extracted data to the CSV file
  # echo "${M_VAL:-NA},${FMAX:-NA},${ALM_TOTAL:-NA},${ALM_LUT_FF:-NA},${ALM_LUT_ONLY:-NA},${ALM_FF_ONLY:-NA},${ALM_MEM:-0},${ALM_VIRTUAL_IO:-NA},${ALUT_ROUTE:-NA},${LAB_TOTAL:-NA},${MEM_LABS:-NA},${HYPER_REG:-NA},${M20K_RAMS:-NA}" >> "$OUT_FILE"
	echo "${M_VAL:-NA},${FMAX:-NA},${ALM_TOTAL:-NA},${ALM_LUT_FF:-NA},${ALM_LUT_ONLY:-NA},${ALM_FF_ONLY:-NA},${ALM_MEM:-0},${ALM_VIRTUAL_IO:-NA},${ALUT_ROUTE:-NA},${LAB_TOTAL:-NA},${MEM_LABS:-NA},${HYPER_REG:-NA},${M20K_RAMS:-NA},${DSP_BLOCKS:-NA}" >> "$OUT_FILE"
done

