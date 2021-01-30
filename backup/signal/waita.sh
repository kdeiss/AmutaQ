#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1 29.9.14
# wait and stop async

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

LOG=$RSYNC_LOG
LOG=$ASYNC_LOG
echo $LOG

##############script detection#########################
LOCKFILE=$SIGNAL/waita
[ -f $LOCKFILE ] && { echo "`date` $0 already active"; exit 1; }

del_lock()
{
    echo "external signal caught, exiting" >> $LOG
    rm -f $LOCKFILE
}

trap "del_lock ; exit 1" 2 9 15
echo $$ > $LOCKFILE
tail -n 20 $LOG 
echo "Async will pause ASAP"

##############script detection#########################
# Sat Apr 26 07:15:19 CEST 2014
# tail -f $LOG

