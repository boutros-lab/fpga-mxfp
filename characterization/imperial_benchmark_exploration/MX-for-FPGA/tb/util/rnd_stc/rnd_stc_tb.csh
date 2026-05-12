#!/bin/csh -xvf

if ( -d temp) then
    cd temp
else
    mkdir temp && cd temp
endif

xsc ../tb/util/rnd_stc/rnd_stc_tb.c 
xvlog --sv -svlog ../tb/util/rnd_stc/rnd_stc_tb.sv ../src/util/rnd/rnd_stc.sv
xelab work.rnd_stc_tb -sv_lib dpi -R

cd ..
