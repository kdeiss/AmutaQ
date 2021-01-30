#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1.1.5.17
# create signal file which will disable autocheck of ddumbfs during mount

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

LOG=$RSYNC_LOG

date > $SIGNAL/donotcheck
