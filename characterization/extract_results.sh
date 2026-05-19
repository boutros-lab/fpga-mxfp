#!/bin/bash
# Extracts FMAX, ALM Usage and DSP Usage from specified project
# Usage: ./extract_results.sh <project_name> <project_directory>

PROJ_NAME=$1
PROJ_PATH=$2

A=`grep -m 1 "\[A\]" $PROJ_PATH/$PROJ_NAME.fit.place.rpt | sed "s/;[^0-9]*;//" | sed "s/,//g" | awk '{print $1}'`
B=`grep -m 1 "\[B\]" $PROJ_PATH/$PROJ_NAME.fit.place.rpt | sed "s/;[^0-9]*;//" | sed "s/,//g" |awk '{print $1}'`

ln=`grep -n "; Restricted Fmax ;" $PROJ_PATH/$PROJ_NAME.sta.rpt | cut -d: -f1 | head -n1`
ln=$((ln + 2))

Fmax=`head -n $ln $PROJ_PATH/$PROJ_NAME.sta.rpt | tail -1 | cut -d ';' -f3 | cut -d " " -f2`

alm_usage=$((A-B))

dsp_usage=`grep -m 1 "DSP Blocks Needed" $PROJ_PATH/$PROJ_NAME.fit.place.rpt | sed "s/;[^0-9]*;//" | sed "s/,//g" | awk '{print $1}'`


echo "$1,$Fmax,$alm_usage,$dsp_usage"
