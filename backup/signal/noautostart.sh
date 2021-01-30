#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1 16.3.15
# 

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

LOG=$RSYNC_LOG

#Sat Apr 26 07:15:19 CEST 2014
date > $SIGNAL/noautostart

echo "ON NEXT BOOT THE BACKUP SYSTEM WILL NOT START AUTOMATICALLY!"
