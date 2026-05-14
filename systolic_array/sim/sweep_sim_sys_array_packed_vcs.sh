#!/bin/bash
# Sweep VCS simulations for sys_array_packed_mult_tb across MXFP format configurations.
# Run from any directory; the script cd's to its own location first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

QUARTUS_INSTALL_DIR=$QUARTUS_ROOT
TOP_LEVEL_NAME="sys_array_packed_mult_tb"

# Parallel arrays: one entry per configuration
EXP_WS=( 3   4   5 )
MAN_WS=( 2   3   2 )

LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"

declare -a RESULTS=()

NUM_CONFIGS=${#EXP_WS[@]}

for (( i=0; i<NUM_CONFIGS; i++ )); do
    EXP_W=${EXP_WS[$i]}
    MAN_W=${MAN_WS[$i]}

    LOG="$LOG_DIR/sweep_vcs_sim_sa_packed_log_E${EXP_W}_M${MAN_W}.txt"

    echo "============================================================"
    echo "Config $((i+1))/$NUM_CONFIGS: EXP_W=$EXP_W MAN_W=$MAN_W"
    echo "Log: $LOG"
    echo "============================================================"

    rm -rf simv simv.daidir csrc ucli.key DVEfiles .vlogan .vhdlan work inter.vpd *.vpd

    PVALUE="-pvalue+${TOP_LEVEL_NAME}/EXP_W=${EXP_W}"
    PVALUE="$PVALUE -pvalue+${TOP_LEVEL_NAME}/MAN_W=${MAN_W}"

    USER_DEFINED_ELAB_OPTIONS="+vcs+lic+wait -debug_access+pp $PVALUE"

    # Compile + elaborate
    set +e
    bash setup_sim_sys_array_packed_vcs.sh \
        QUARTUS_INSTALL_DIR="$QUARTUS_INSTALL_DIR" \
        USER_DEFINED_ELAB_OPTIONS="\"$USER_DEFINED_ELAB_OPTIONS\"" \
        SKIP_SIM=1 \
        TOP_LEVEL_NAME="$TOP_LEVEL_NAME" \
        EXP_W="$EXP_W" \
        MAN_W="$MAN_W" \
        > "$LOG" 2>&1
    SETUP_STATUS=$?
    set -e

    if [ $SETUP_STATUS -ne 0 ] || [ ! -x ./simv ]; then
        echo "  -> FAILED (elaboration)"
        RESULTS+=("FAILED (elab)  EXP_W=$EXP_W MAN_W=$MAN_W")
        continue
    fi

    # Simulate (batch, no GUI)
    ./simv +vcs+lic+wait >> "$LOG" 2>&1

    if grep -q "TEST PASSED" "$LOG"; then
        echo "  -> PASSED"
        RESULTS+=("PASSED         EXP_W=$EXP_W MAN_W=$MAN_W")
    else
        echo "  -> FAILED (simulation)"
        RESULTS+=("FAILED (sim)   EXP_W=$EXP_W MAN_W=$MAN_W")
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
