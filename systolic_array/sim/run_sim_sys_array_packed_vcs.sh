QUARTUS_INSTALL_DIR=$QUARTUS_ROOT
USER_DEFINED_ELAB_OPTIONS="+vcs+lic+wait -debug_access+pp"
#USER_DEFINED_ELAB_OPTIONS="+vcs+lic+wait"
SKIP_SIM=1
TOP_LEVEL_NAME="sys_array_packed_mult_tb"

sh setup_sim_sys_array_packed_vcs.sh QUARTUS_INSTALL_DIR=$QUARTUS_INSTALL_DIR USER_DEFINED_ELAB_OPTIONS="\"$USER_DEFINED_ELAB_OPTIONS\"" SKIP_SIM=$SKIP_SIM TOP_LEVEL_NAME=$TOP_LEVEL_NAME > rtl_sim_log

#./simv -gui -dve_opt "-session=sa_aitb_tb_wave.tcl" +vcs+lic+wait
./simv -gui +vcs+lic+wait
