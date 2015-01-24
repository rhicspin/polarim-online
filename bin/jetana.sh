#!/bin/bash
# Analize(reanalize) jet run

. polsetvar.sh

RUN=$1

export HJET_ROOTFILE="$POLSTORE/root/"$RUN".root"
export HJET_DATAFILE="$POLSTORE/data/"$RUN".data"
export HJET_DAQ=""

export HJET_CALIB="${POLCONF}/calib_${2:-1403.904}.dat"  # Run13
if [ "x"$1 == "x" ] ; then 
    echo "Usage: ./jetanal.sh <RUN> [<CALIB>]"
else
# to run in background (no displays) use -b
#    root -b jetrun.C 
# to run in forground (display during analysis) use -l
    root -l jetrun.C
fi
