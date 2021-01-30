#! /bin/bash
# by k.deiss@it-userdesk.de
# acces to logfile from webmin
# V 0.0.1 29.9.14
# V 0.0.2 2.1.16 nugfix

#don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf

tmp="/tmp/log2.log"
asynclock="/tmp/asynccopy.lck"
asynclog="/var/log/async.log"
mainlog="/var/log/nfs1.log"


echo ""
echo "-----------------------------------------------------------------------------"
echo "                  Full Log (direct write to DDUMBFS/BUFFERDISK)                  "
echo "-----------------------------------------------------------------------------"



tail -n 1000 $mainlog > $tmp

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
echo "-----------------------------------------------------------------------------"
echo "                  Full Log (writes from bufferdisk to DDUMBFS)        "
echo "-----------------------------------------------------------------------------"

tail -n 600 $asynclog  > $tmp

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
