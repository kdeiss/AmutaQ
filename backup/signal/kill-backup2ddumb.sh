#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1 29.12.22
# kill the main backup processes

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf
LOG=$RSYNC_LOG
TMP="/tmp/$$.tmp"


echo "`date` INF $0 startup - try to kill all AmutaQ! related processes."

ps -aux |grep backup2ddumb

killall -9 backup2ddumb-aux
killall -9 backup2ddumb

ps -aux |grep backup2ddumb


#falls vorhanden wait löschen
if [ -f $SIGNAL/wait ] ;then
    rm $SIGNAL/wait
    echo "`date` INF $SIGNAL/wait deleted."
else
    echo "`date` INF $SIGNAL/wait not found."
fi


#falls vorhanden backup2ddumb.lck löschen
if [ -f /tmp/backup2ddumb.lck ] ;then
    rm -f /tmp/backup2ddumb.lck
    echo "`date` INF /tmp/backup2ddumb.lck deleted"
else
    echo "`date` INF /tmp/backup2ddumb.lck not found"
fi

echo "`date` WAR backup2ddumb and backup2ddumb-aux killed." >> $LOG
echo "" >> $LOG

ps -aux |grep backup2ddumb
