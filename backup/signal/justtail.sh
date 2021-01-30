#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1 29.9.14
# tail central log

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

LOG=$RSYNC_LOG
echo $LOG

tail -f $LOG

