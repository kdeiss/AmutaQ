#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1 1.5.14
# stop async backups

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

LOG=$RSYNC_LOG

#Sat Apr 26 07:15:19 CEST 2014
date > $SIGNAL/astop
