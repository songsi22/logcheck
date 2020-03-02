#!/bin/ksh
filename=`date +"DR_MONTHLY.log.%Y%m"`
tail -1 $filename
logcheck(){
cri=0
trap break 2
trap 'cri=0;rm -rf core;break' 3
while true
do
        filename=`date +"DR_MONTHLY.log.%Y%m"`
        tail -fn0 $filename | \
        while read line
                do
                linesc=`echo -e \'$line\'|awk '{print $7}'`
                if [[ "Critical." == $linesc ]] || [[ "Failure" == $linesc ]]; then
                        cri=1
                        echo '\033[0;41m\033[7m'$line'\033[0m'
                        wc1=`cat $filename|wc -l`
                        wc2=`cat $filename|wc -l`
                        while [ $wc1 == $wc2 ]
                        do
                                printf '\007'
                                wc1=`cat $filename|wc -l`
                                sleep 3
                        done
                elif [ "Warning" == "$linesc" ]; then
                        if [ $cri == 0 ]; then
                                echo '\033[0;33m'$line'\033[0m'
                        else
                                wc1=`cat $filename|wc -l`
                                wc2=`cat $filename|wc -l`
                                echo '\033[0;36m'$line'\033[0m'
                                while [ $wc1 == $wc2 ]
                                do
                                        printf '\007'
                                        wc1=`cat $filename|wc -l`
                                        sleep 3
                                done
                        fi
                else
                        if [ $cri == 0 ]; then
                                echo $line
                        else
                                wc1=`cat $filename|wc -l`
                                wc2=`cat $filename|wc -l`
                                echo '\033[0;36m'$line'\033[0m'
                                while [ $wc1 == $wc2 ]
                                do
                                        printf '\007'
                                        wc1=`cat $filename|wc -l`
                                        sleep 3
                                done
                        fi

                fi
        done
done
}
logcheck 2> /dev/null
