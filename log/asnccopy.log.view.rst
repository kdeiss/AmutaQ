#! /bin/bash
# by k.deiss@it-userdesk.de
# extract most important meg from log
# V 0.0.1.27.12.15
# V 0.0.2.4.10.19

tmp="/tmp/compressed2.log"
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

