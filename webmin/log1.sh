#! /bin/bash
# by k.deiss@it-userdesk.de
# extract most important meg from all log
# V 0.0.1 29.9.14
# V 0.0.2.27.12.15
# V 0.0.3.11.1.16 bugfix df -hl
# V 0.0.4.12.1.16 bugfix /sbin/blkid
# V 0.0.5.26.11.19 bugfix grep WAR ERR add space

#don't edit from here
source /opt/AmutaQ!/etc/AmutaQ!.conf
source /opt/AmutaQ!/lib/discident.lib
# usage echo "HDD `trans-discnames $i` could be removed."


tmp="/tmp/log1.log"
asynclock="/tmp/asynccopy.lck"
asynclock1="/tmp/asynccopy-aux.lck"
asynclog="/var/log/async.log"
mainlog="/var/log/nfs1.log"

BAZAARLOGDIR="/opt/AmutaQ!/backup"
BAZAARLOGFN="bazaarvcb.log"
BUFFERREPORT="/opt/AmutaQ!/bazaar/vm_make_report_bufferdisk"

statfn="/tmp/cpustat.txt"
logfn="/var/log/cpu-stat-log"

function get-ckpids
{
date > $tmp
ps -xa >> $tmp

ckps="/tmp(ckctr.tmp"
echo -n "" > $ckps
let ckctr=0
while read line 
do
    echo $line | grep cksum >> $ckps
    if [ $? -eq 0 ] ; then
	let ckctr=$ckctr+1
    fi
done < $tmp

if [ $ckctr -gt 0 ] ; then
    echo "`date` INF $ckctr process(es) of cksum (crc32 check) running:"
    cat $ckps
else
    echo "`date` INF cksum (crc32 check) not running."
fi
rm $ckps
}



function countvm
{
for VMCTRTEMP in $VMLIST
    do
        let ctr=$ctr+1
    done
}

function ddumbreport
{
let i=0
let ctr=0
if [ -f /opt/AmutaQ!/etc/AmutaQ!.conf.$i ];then
    echo "This system is backing up multiple ESXi Hosts - rotation config found."
    let i=0
    while [ $i -lt 10 ];do
	if [ -f /opt/AmutaQ!/etc/AmutaQ!.conf.$i ];then
	    source /opt/AmutaQ!/etc/AmutaQ!.conf.$i
	    countvm
	else
	    break
	fi
	let i=$i+1
    done
else
    countvm
fi

echo "$ctr VM's to backup from $i machines."

let actr=0
for RSTSTRING in `df -hl | grep $DDUMBVOL`
do
    if [ $actr -eq 4 ] ; then
        let PERCENTAGE=`echo $RSTSTRING|cut -f 1 -d %`
    fi

    if [ $actr -eq 0 ] ; then
        DDUMBMOUNT="$RSTSTRING"
	DDUMBMOUNT=`dirname $DDUMBMOUNT`
	DDUMBMOUNT=`dirname $DDUMBMOUNT`
	df -hl | grep "$DDUMBMOUNT"
    fi
    let actr=$actr+1
done
echo "TARGET $DDUMBVOL is filled to $PERCENTAGE%"
ANZBACKUP=`find $ASYNCTARGET -type d 2>/dev/null |wc -l`
echo "$ANZBACKUP Backups found on $ASYNCTARGET"
}



function showbackupdisk
{
DDUMB=`mount | grep ddumbfs`
/sbin/blkid > /tmp/blkid.txt
echo "`date` INF Disc overview:"
for i in  $DDDEVICELIST
do
    bid=`cat /etc/fstab | grep $i`
    #echo $bid
    if [ ! -z "$bid" ] ; then 
	cat /tmp/blkid.txt | grep `echo $bid | cut -f 1 -d " " | cut -f 2 -d "="` 2>/dev/null>/dev/null
	if [ $? -eq 0 ] ; then 
	    #echo $i connected
	    echo $DDUMB | grep $i > /dev/null
	    if [ $? -eq 0  ] ; then
		TARGETHD=$i
	    else
		CURCHKDSK=`mount | grep /mnt/$i`
		if [ -z "$CURCHKDSK" ];then
		    echo "HDD `trans-discnames $i` could be removed."
		    let UMOUNT=0
		else
	    	    echo "HDD `trans-discnames $i` could be removed - but is currently mounted."
		fi
	    fi
	else
    	    echo "HDD `trans-discnames $i` not connected to the system."
	fi
    else
	echo "HDD `trans-discnames $i` has no entry in /etc/fstab !!!"
    fi
done
echo "Currently in use: `trans-discnames $TARGETHD`."
}


echo "-----------------------------------------------------------------------------"
echo "                  Quick overview ($VERSION)                                  "
echo "-----------------------------------------------------------------------------"
echo ""
ls $SIGNAL | while read line
do
    echo $line | egrep ".sh|README" > /dev/null
    if [ $? -eq 1 ] ;then
	echo "`date` INF Found active signal: $line"
    fi
done

echo ""
echo ""
PIDB=`pidof $BAZAARVCB`
if [ -z "$PIDB" ] ; then
    echo "`date` INF Bazaar-Backup not running."
    tail -n 1 $mainlog
else
    echo "`date` INF Bazaar-Backup in progress  - current state:"
    tail -n 10 $mainlog | grep "be written"
    tail -n 4 $BAZAARLOGDIR/$BAZAARLOGFN
fi
echo ""
echo ""


let g=0
for f in `ls -rt $SPOOLDIR`
    do
	let g=$g+1
    done
echo "`date` INF Async jobs in Queue: $g"
echo ""
echo ""


if [ -f $asynclock ] || [ -f $asynclock1 ]  ; then
    echo "`date` INF Async-Backup in progress  - current state:"
    tail -n 4 $asynclog
else
    echo "`date` INF No active Async-Backup running."
fi
echo ""
echo ""

get-ckpids
echo ""
echo ""

echo "`date` INF BufferDisk statistic:"
$BUFFERREPORT
echo ""
echo ""

echo "`date` INF DDUMBFS statistic:"
ddumbreport
echo ""
echo ""

echo "`date` INF CPU statistic (last 24H):"
head -n 1 $logfn
tail -n 24 $logfn
echo ""
echo ""

showbackupdisk
echo ""
echo ""


echo "-----------------------------------------------------------------------------"
echo "              Last activities (Writes from ESXi to DDUMBFS and BUFFERDISK)   "
echo "-----------------------------------------------------------------------------"

cat $mainlog |egrep "start backup|ERR |WAR |temporary|write descrip|blocks|be written|kill |with VID" > $tmp

if [ -f $tmp ] ; then
    while read line
    do
	echo "$line" | egrep "be written|kill" > /dev/nul
	if [ -$? -eq 0 ] ; then
	    echo ""
	    echo $line
	else
	    echo "$line" | grep "ERR " > /dev/nul
	    if [ -$? -eq 0 ] ; then
		echo "!!!!!!!!!!!!!   $line   !!!!!!!!!!!!!!!!!!!!!!"
	    else
		echo $line
	    fi
	fi
    done < $tmp
else
    echo "ERROR in $tmp"
fi
echo ""
echo ""
echo "-----------------------------------------------------------------------------"
echo "               Last activities (Writes from BUFFERDISK to DDUMBFS)           "
echo "-----------------------------------------------------------------------------"

# cat async.log |egrep "start copy|ERR |WAR |sent|speedup|finished CRC check| copy \(ID" > $tmp
tail -n 2000 $asynclog |egrep "start copy|ERR |WAR |both copies|finished CRC check|copy to |background" > $tmp

if [ -f $tmp ] ; then
    while read line
    do
	echo "$line" | grep "start copy" > /dev/nul
	if [ -$? -eq 0 ] ; then
	    echo ""
	    echo $line
	else
	    echo "$line" | grep "ERR" > /dev/nul
	    if [ -$? -eq 0 ] ; then
		echo "!!!!!!!!!!!!!   $line   !!!!!!!!!!!!!!!!!!!!!!"
	    else
		echo $line
	    fi
	fi



    done < $tmp

else
    echo "ERROR in $tmp"
fi
