#!/bin/bash

. polsetvar.sh
LOGDIR=$POLSTORE/log

case $POLRING in
    blue   ) RING="B" ;;
    yellow ) RING="Y" ;;
    *      ) echo "Wrong ring !!!"; exit     ;;
esac

export LD_LIBRARY_PATH=$POLARIM/lib:$LD_LIBRARY_PATH
${POLBIN}/rpoldaemon -$RING -l ${LOGDIR}/rpoldaemon.log -r ${POLBIN}/rpolmeasure.sh 
