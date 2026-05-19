#!/bin/csh -xvf

if ( -d temp) then
    cd temp
else
    mkdir temp && cd temp
endif

xsc ../tb/util/rnd_rne/rnd_rne_tb.c 
xvlog --sv -svlog ../tb/util/rnd_rne/rnd_rne_tb.sv ../src/util/rnd/rnd_rne.sv
xelab work.rnd_rne_tb -sv_lib dpi -R

cd ..
