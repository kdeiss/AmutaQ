#Mi 30. Apr 08:22:15 CEST 2014

LOG="./rc_$$.log"

#check parms

if [ -z $1 ]; then
    echo `date` "usage $0 SOURCE TARGET" | tee $LOG
    exit 1
fi

if [ -z $2 ]; then
    echo `date` "usage $0 SOURCE TARGET" | tee $LOG
    exit 1
fi

if [ ! -d $1 ]; then
    echo `date` "invalid source - usage $0 SOURCE TARGET" | tee $LOG
    exit 1
else
    S=$1    
fi

if [ ! -d $2 ]; then
    echo `date` "invalid target - usage $0 SOURCE TARGET" | tee $LOG
    exit 1
else
    T=$2
fi


echo `date` "start rsync ! /usr/bin/rsync -rltzuv $S $T" | tee $LOG
/usr/bin/rsync -rltzuv "$S" "$T" 2>&1 | tee -a $LOG
if [ $? -eq 0 ] ;then
    echo `date` "rsync ok !"| tee -a $LOG
else
    echo `date` "rsync failure !"| tee -a $LOG
    let EXITSTAT=1
fi
