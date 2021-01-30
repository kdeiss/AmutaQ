#! /bin/bash
# by k.deiss@it-userdesk.de
# V 0.0.1 1.5.14
# kill all 

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf
LOG=$RSYNC_LOG
TMP="/tmp/$$.tmp"

##############script detection#########################
del_lock()
{
    kill -9 $TID
}

trap "del_lock ; exit 1" 2 9 15
##############script detection#########################




function killprocs()
{
    pslist="crccheck crccheckS cksum bazaarvcb"
    ps -e > $TMP 

    cat $TMP | grep " bazaarvcb" > /dev/null
    if [ $? -eq 0 ];then
	echo "bazaarvcb is running - you will have spoiled backups - don't forget to clean all *.new directories!"
    fi

    for i in $pslist ; do
	cat $TMP | grep " $i" > /dev/null
	if [ $? -eq 0 ];then
	    echo "`date` INF try to kill $i!" >> $LOG
	    killall -9 $i 2>&1
	else
	    echo "`date` INF no instance of $i running" >> $LOG
	fi
    done 
    rm $TMP
}

echo "" >> $LOG
echo "`date` INF $0 startup - try to kill all AmutaQ! related processes." >> $LOG
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
TID=$?
echo "`date` INF tail running with $TID"
echo "`date` INF try to kill all our procedures"
killprocs

echo "`date` INF looking for asynccopy"
while [ -f /tmp/asynccopy.lck ]
do
    if [ $wctr -gt 5 ] ; then 
	let wctr=0
    fi

    if [ $wctr -eq 0 ] ; then 
	echo "`date` INF asynccopy still running"
	killprocs
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
	echo "`date` INF backup2ddumb still running - be patient"
	killprocs
	let wctr=0
    fi

    let wctr=$wctr+1
    sleep 10
done

echo "`date` INF backup2ddumb done. Killing tail."
echo "`date` INF $0 AmutaQ! hard shutdown comleted." >> $LOG
kill -9 $TID
