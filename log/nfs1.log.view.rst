#! /bin/bash
# by k.deiss@it-userdesk.de
# extract most important meg from log
# V 0.0.1.27.12.15
# V 0.0.2.4.10.19

tmp="/tmp/compressed.log"

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf




BAZAARLOGDIR="/opt/AmutaQ!/backup"
BAZAARLOGFN="bazaarvcb.log"
BUFFERREPORT="/opt/AmutaQ!/bazaar/vm_make_report_bufferdisk"



echo "-----------------------------------------------------------------------------"
echo "                  Last activities (writes from bufferdisk to DDUMBFS)        "
echo "-----------------------------------------------------------------------------"

# cat async.log |egrep "start copy|ERR |WAR |sent|speedup|finished CRC check| copy \(ID" > $tmp
#tail -n 600 async.log |egrep "start copy|ERR |sent|speedup|finished CRC check| copy \(ID" > $tmp
tail -n 2000 async.log |egrep "start copy|ERR |succes|.lck|speedup|finished CRC check| copy \(ID" > $tmp


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



echo ""
echo ""
echo "-----------------------------------------------------------------------------"
echo "                  Last activities (direct write to DDUMBFS/BUFFERDISK)                  "
echo "-----------------------------------------------------------------------------"

tail -n 10000 nfs1.log |egrep "start backup|ERR|WAR|temporary|write descrip|completed|Duration|blocks|be written" > $tmp

if [ -f $tmp ] ; then
    while read line
    do
	echo "$line" | grep "be written" > /dev/nul
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
echo ""
echo ""


PIDB=`pidof $BAZAARVCB`
if [ -z "$PIDB" ] ; then
    echo ""
    echo "`date` INF No active Backup running."
    exit 0
else
    echo ""
    echo "`date` INF Backup in progress  - current state:"
fi

tail -n 4 $BAZAARLOGDIR/$BAZAARLOGFN

echo ""
let g=0
for f in `ls -rt $SPOOLDIR`
    do
	let g=$g+1
    done

echo "`date` INF Copy jobs in Queue: $g"

echo ""
echo "`date` INF BufferDisk statiatic"
$BUFFERREPORT

