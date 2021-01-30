#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1 1.5.14
# end all jobs then quit
# V 0.0.2 25.12.15 spoolfiles NICHT loeschen / wait files loeschen damit der stop zum Einsatz kommt!
# V 0.0.3 10.12.16 automatic szop after done


#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

LOG=$RSYNC_LOG
OB

##############script detection#########################
del_lock()
{
    kill -9 $TID
}

trap "del_lock ; exit 1" 2 9 15
##############script detection#########################

echo "" >> $LOG
echo "`date` INF $0 startup - try to stop all AmutaQ! related processes the soft and recommended way." >> $LOG

#stop sigaml file erzeugen
date > $SIGNAL/stop

#falls vorhanden wait und waita loeschen - ansonsten kann stop signal nicht verarbeitet werden
if [ -f $SIGNAL/wait ] ;then
    rm $SIGNAL/wait
fi

if [ -f $SIGNAL/waita ] ;then
    rm $SIGNAL/waita
fi

let wctr=0

tail -f $LOG &
TID=$!
echo "`date` INF tail running with $TID"


tail -f $ASYNC_LOG &
TID1=$!
echo "`date` INF tail running with $TID1"
echo "`date` INF try to stop all our procedures"


echo "`date` INF looking for asynccopy"
while [ -f /tmp/asynccopy.lck ]
do
    if [ $wctr -gt 5 ] ; then 
	let wctr=0
    fi

    if [ $wctr -eq 0 ] ; then 
	echo "`date` INF asynccopy still running"
	let wctr=0
    fi

    let wctr=$wctr+1
    sleep 10
done
echo "`date` INF asynccopy done."


echo "`date` INF looking for backup2ddumb"
while [ -f /tmp/backup2ddumb.lck ]
do
    if [ $wctr -gt 5 ] ; then 
	let wctr=0
    fi

    if [ $wctr -eq 0 ] ; then 
	echo "`date` INF backup2ddumb still running - be patient!"
	let wctr=0
    fi

    let wctr=$wctr+1
    sleep 10
done

echo "`date` INF backup2ddumb done. Killing tail."
echo "`date` INF $0 AmutaQ! soft shutdown comleted." >> $LOG
kill -9 $TID
kill -9 $TID1

#falls vorhanden wait und waita loeschen - ansonsten kann stop signal nicht verarbeitet werden
if [ -f $SIGNAL/wait ] ;then
    rm $SIGNAL/wait
fi

if [ -f $SIGNAL/waita ] ;then
    rm $SIGNAL/waita
fi

if [ -f $SIGNAL/stop ] ;then
    rm $SIGNAL/stop
fi

reboot

exit 0
