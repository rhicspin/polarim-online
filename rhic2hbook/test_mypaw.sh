#!/usr/bin/sh
#RUN=14802.016
#RUN=14802.114
#RUN=14802.207
#RUN=14802.307
RUN=$1

POLDIR=/home/polarim
LOGDIR=/home/blue/2022/log
#PSFILE=${LOGDIR}/${RUN}.ps
HBOOKDIR=/home/blue/2022/hbook
HBOOKFILE=${HBOOKDIR}/${RUN}.hbook
BINDIR=${POLDIR}/bin
MACDIR=${BINDIR}

#MACDIR=/usr/local/cnipol_trunk/online/rhic2hbook
PSFILE=test_mypaw.ps

$MACDIR/pvector.pl $RUN

export RUN LOGDIR PSFILE HBOOKFILE MACDIR # no other way to pass arguments to kumac...

$MACDIR/pvector.pl $RUN

$POLDIR/bin/pawX11 -n -b $MACDIR/onliplot.kumac

#gv $PSFILE &

