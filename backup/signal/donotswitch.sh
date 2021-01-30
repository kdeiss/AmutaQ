#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1.1.5.17
# create signal file which supress disk switching

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

LOG=$RSYNC_LOG

date > $SIGNAL/donotswitch
