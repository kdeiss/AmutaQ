#! /bin/bash
# by k.deiss@it-userdesk.de
# webmin interface - which device could be removed
# V 0.0.1 29.9.14
# V 0.0.2 29.12.15 trans-discnames ausgelagert in LIB
# V 0.0.3 1.3.17 bugfix
# V 0.0.4 1.4.17 blkid not working if called from main script
# V 0.0.5.12.9.19 luks beta
# V 0.0.6.23.9.19 nfs status
# V 0.0.7.5.10.19 ah detect if /etc/crypttab is available
# V 0.0.8.5.10.19 ah give info if backup is finished or not
# V 0.0.6.24.11.19 ah show last backup-device, when backup is finished
# V 0.0.7.14.12.19 ah filter commented(#) lines from fstab and crypttab
# V 0.0.8.26.8.21  ah also try to close crypt after umount

BEFOREDEVICE="/tmp/last_backup_vol"
# don't edit from here

source /opt/AmutaQ!/etc/AmutaQ!.conf
source /opt/AmutaQ!/lib/discident.lib
# usage echo "HDD `trans-discnames $i` could be removed."

BLKID=`which blkid`
DDUMB=`mount | grep ddumbfs`
let UMOUNT=2

$BLKID> /tmp/blkid.txt
echo ""
for i in  $DDDEVICELIST
do
    bid=`cat /etc/fstab | grep $i | grep -v "#"`

    # echo "BID: $bid"
    if [ ! -z "$bid" ] ; then 
	cat /tmp/blkid.txt | grep `echo $bid | cut -f 1 -d " " | cut -f 2 -d "="` 2>/dev/null>/dev/null
	if [ $? -eq 0 ] ; then 
	    # echo "Disk: $i connected"
	    echo $DDUMB | grep $i > /dev/null
	    if [ $? -eq 0  ] ; then
		# echo "Disk: $i is DDUMB"
		TARGETHD=$i
	    else
		CURCHKDSK=`mount | grep /mnt/$i`
		if [ -z "$CURCHKDSK" ];then
		    echo "HDD `trans-discnames $i` could be removed."
		    let UMOUNT=0
		else
	    	    echo "HDD `trans-discnames $i` could be removed - but is currently mounted."
		    echo "try to umount `trans-discnames $i` ......."
		    umount /mnt/$i
		    sleep 2
		#luks: close crypting when crypted
		    opencount=$(dmsetup info -c --noheadings -o open "$i" 2>/dev/null || true)
		    if [ "$opencount" ]; then
		#  echo Open $opencount | tee -a $LOG
			let wctr=0
			while [ "$opencount" != "0" ]
			do
			    let wctr=$wctr+1
			    umount /mnt/$i >/dev/null
			    if [ $wctr -gt 10 ] ; then
			#abort with error
				echo "can't umount $i."
        			break
			    fi
			    sleep 2
			    opencount=$(dmsetup info -c --noheadings -o open "$i" 2>/dev/null || true)
			done
			#stop crypt
			cryptdisks_stop $i
		    fi

		    CURCHKDSK=`mount | grep /mnt/$i`
		    if [ -z "$CURCHKDSK" ];then
			echo "HDD `trans-discnames $i` could be removed."
			let UMOUNT=0
		    else
		        echo "HDD `trans-discnames $i` could be removed - but is still mounted. Call support"
			let UMOUNT=1
		    fi
		fi
	    fi
	else
#5.10.19 check if crypttab is available before reading
	    cbid=""
	    if [ -r /etc/crypttab ]; then
		cbid=`cat /etc/crypttab | grep $i| grep -v "#"`
	    fi
	    if [ ! -z "$cbid" ] ; then
		#disk is encrypted, but is not mounted. Check if connected.
		cat /tmp/blkid.txt | grep `echo $cbid | cut -f 2 -d " " | cut -f 2 -d "="` 2>/dev/null>/dev/null
		if [ $? -eq 0 ] ; then
		    echo "HDD `trans-discnames $i` could be removed (crypted)."
		    let UMOUNT=0
		else
    	            echo "HDD `trans-discnames $i` not connected to the system (crypted)."
		fi
	    else
#V 0.0.6.23.9.19 nfs status
		nbid=`cat /etc/fstab | grep $i | grep nfs | grep -v "#"`
		if [ ! -z "$nbid" ] ; then
	            echo $DDUMB | grep $i > /dev/null
	            if [ $? -eq 0  ] ; then
	                # echo "Disk: $i is DDUMB"
	                TARGETHD=$i
		    else
			SRV=`echo $nbid |cut -f 1 -d ":"`
			SRVFS=`echo $nbid |cut -f 2 -d ":" |cut -f 1 -d " "`
			EXPORT=`showmount -e $SRV | grep $SRVFS`
			if [ ! -z "$EXPORT" ] ; then
			    echo "HDD `trans-discnames $i` is connected via NFS."
			    let UMOUNT=0
			fi
		    fi
		else
	    	    echo "HDD `trans-discnames $i` not connected to the system."
		fi
	    fi
	fi
    else
	echo "HDD `trans-discnames $i` has no entry in /etc/fstab !!!"
    fi
done

echo ""
echo ""
#echo ""
echo "Currently in use: `trans-discnames $TARGETHD`."
echo ""

#5.10.19 ah: show info if Backup is finished or not
if [ -f $SIGNAL/softswitch ] ; then
    echo "Backup is still running. Don't change disk now!"
else
    if [ -f $SIGNAL/wait ] ; then
        echo "Backup is finished. Disk can be changed now"
	if [ -f $BEFOREDEVICE ] ; then
	    LASTDEV=`cat "$BEFOREDEVICE"`
	    echo "Last used Device: `trans-discnames $LASTDEV`."
	fi
    else
        echo "Backup is running. Don't change disk now!"
    fi
fi

exit $UMOUNT

