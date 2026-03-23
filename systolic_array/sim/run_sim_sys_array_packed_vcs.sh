#!/bin/bash

QUARTUS_INSTALL_DIR=$QUARTUS_ROOT
USER_DEFINED_ELAB_OPTIONS="+vcs+lic+wait -debug_access+pp"
SKIP_SIM=1
TOP_LEVEL_NAME="sys_array_packed_mult_tb"

echo "TOP_LEVEL_NAME = $TOP_LEVEL_NAME"

rm -rf simv simv.daidir csrc ucli.key DVEfiles .vlogan .vhdlan work inter.vpd *.vpd

bash setup_sim_sys_array_packed_vcs.sh \
  QUARTUS_INSTALL_DIR="$QUARTUS_INSTALL_DIR" \
  USER_DEFINED_ELAB_OPTIONS="\"$USER_DEFINED_ELAB_OPTIONS\"" \
  SKIP_SIM=$SKIP_SIM \
  TOP_LEVEL_NAME="$TOP_LEVEL_NAME" \
  > rtl_sim_log 2>&1

setup_status=$?

if [ $setup_status -ne 0 ]; then
  echo "Setup/elaboration failed. Not running simv."
  exit $setup_status
fi

if [ ! -x ./simv ]; then
  echo "Error: simv was not created. Not running simulation."
  exit 1
fi

./simv -gui -dve_opt "-session=sa_packed_wave.tcl" +vcs+lic+wait