#!/bin/bash
# Sweep VCS simulations for sys_array_aitb_prop_tb across 5 MXFP format configurations.
# Run from any directory; the script cd's to its own location first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

QUARTUS_INSTALL_DIR=$QUARTUS_ROOT
TOP_LEVEL_NAME="sys_array_aitb_prop_tb"

# Parallel arrays: one entry per configuration
MODES=(    0   1   2   3   4 )
EXP_WS=(   2   2   3   4   5 )
MAN_WS=(   1   3   2   3   2 )
IS_DOT4S=( 0   0   0   0   1 )

LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

declare -a RESULTS=()

NUM_CONFIGS=${#MODES[@]}

for (( i=0; i<NUM_CONFIGS; i++ )); do
    MODE=${MODES[$i]}
    EXP_W=${EXP_WS[$i]}
    MAN_W=${MAN_WS[$i]}
    IS_DOT4=${IS_DOT4S[$i]}

    LOG="$LOG_DIR/sweep_vcs_sim_log_MODE${MODE}_E${EXP_W}_M${MAN_W}.txt"

    echo "============================================================"
    echo "Config $((i+1))/$NUM_CONFIGS: MODE_INT=$MODE EXP_W=$EXP_W MAN_W=$MAN_W IS_DOT4=$IS_DOT4"
    echo "Log: $LOG"
    echo "============================================================"

    rm -rf simv simv.daidir csrc ucli.key DVEfiles .vlogan .vhdlan work inter.vpd *.vpd

    PVALUE="-pvalue+${TOP_LEVEL_NAME}/MODE_INT=${MODE}"
    PVALUE="$PVALUE -pvalue+${TOP_LEVEL_NAME}/EXP_W=${EXP_W}"
    PVALUE="$PVALUE -pvalue+${TOP_LEVEL_NAME}/MAN_W=${MAN_W}"
    PVALUE="$PVALUE -pvalue+${TOP_LEVEL_NAME}/IS_DOT4=${IS_DOT4}"

    USER_DEFINED_ELAB_OPTIONS="+vcs+lic+wait -debug_access+pp $PVALUE"

    # Compile + elaborate
    set +e
    bash setup_sim_sys_array_aitb_prop_vcs.sh \
        QUARTUS_INSTALL_DIR="$QUARTUS_INSTALL_DIR" \
        USER_DEFINED_ELAB_OPTIONS="\"$USER_DEFINED_ELAB_OPTIONS\"" \
        SKIP_SIM=1 \
        TOP_LEVEL_NAME="$TOP_LEVEL_NAME" \
        > "$LOG" 2>&1
    SETUP_STATUS=$?
    set -e

    if [ $SETUP_STATUS -ne 0 ] || [ ! -x ./simv ]; then
        echo "  -> FAILED (elaboration)"
        RESULTS+=("FAILED (elab)  MODE_INT=$MODE EXP_W=$EXP_W MAN_W=$MAN_W IS_DOT4=$IS_DOT4")
        continue
    fi

    # Simulate (batch, no GUI)
    ./simv +vcs+lic+wait >> "$LOG" 2>&1

    if grep -q "TEST PASSED" "$LOG"; then
        echo "  -> PASSED"
        RESULTS+=("PASSED         MODE_INT=$MODE EXP_W=$EXP_W MAN_W=$MAN_W IS_DOT4=$IS_DOT4")
    else
        echo "  -> FAILED (simulation)"
        RESULTS+=("FAILED (sim)   MODE_INT=$MODE EXP_W=$EXP_W MAN_W=$MAN_W IS_DOT4=$IS_DOT4")
    fi
done

echo ""
echo "============================================================"
echo "SWEEP SUMMARY"
echo "============================================================"
for r in "${RESULTS[@]}"; do
    echo "  $r"
done
echo "============================================================"
