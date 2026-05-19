#!/bin/bash
# Sweep Modelsim simulations for sys_array_aitb_prop_tb across 5 MXFP format configurations.
# Run from any directory; the script cd's to its own location first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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

    LOG="$LOG_DIR/sweep_modelsim_sim_sa_aitb_prop_log_MODE${MODE}_E${EXP_W}_M${MAN_W}.txt"

    echo "============================================================"
    echo "Config $((i+1))/$NUM_CONFIGS: MODE_INT=$MODE EXP_W=$EXP_W MAN_W=$MAN_W IS_DOT4=$IS_DOT4"
    echo "Log: $LOG"
    echo "============================================================"

    SIM_OPTIONS="-gMODE_INT=${MODE} -gEXP_W=${EXP_W} -gMAN_W=${MAN_W} -gIS_DOT4=${IS_DOT4}"

    set +e
    bash run_sim_sys_array_aitb_prop_modelsim.sh \
        TOP_LEVEL_NAME="$TOP_LEVEL_NAME" \
        USER_DEFINED_SIM_OPTIONS="\"$SIM_OPTIONS\"" \
        > "$LOG" 2>&1
    RUN_STATUS=$?
    set -e

    if [ $RUN_STATUS -ne 0 ]; then
        echo "  -> FAILED (compile/sim error)"
        RESULTS+=("FAILED (error)  MODE_INT=$MODE EXP_W=$EXP_W MAN_W=$MAN_W IS_DOT4=$IS_DOT4")
        continue
    fi

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
