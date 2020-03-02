if [ "$#" -lt 1 ]; then
	cri=0    
elif [ "$1" -eq 1 ]; then
	cri=1
else 
	print "if you want to manual mode."
	print "sh $0 1"
fi
logcheck(){
currentfilename=`ls -lt DR_MONTHLY.log.* | head -1|awk '{print $9}'`
wc1=`cat $currentfilename|wc -l` 
trap break 2
trap 'cri=0;rm -rf core;break' 3
while true
do
	wc2=`cat $currentfilename|wc -l` 
	if [ $wc1 != $wc2 ]; then
		line=`tail -1 $currentfilename`
		linesc=`echo -e \'$line\'|awk '{print $7}'`
		if [[ "Critical." == $linesc ]] || [[ "Failure" == $linesc ]]; then
                        cri=1
                        echo '\033[0;41m\033[7m'$line'\033[0m'
                        wc1=`cat $currentfilename|wc -l`
                        wc2=`cat $currentfilename|wc -l`
                        while [ $wc1 == $wc2 ]
                        do
                                printf '\007'
                                wc1=`cat $currentfilename|wc -l`
                                sleep 3
                        done
                elif [ "Warning" == "$linesc" ]; then
                        if [ $cri == 0 ]; then
                                echo '\033[0;33m'$line'\033[0m'
                        else
                                wc1=`cat $currentfilename|wc -l`
                                wc2=`cat $currentfilename|wc -l`
                                echo '\033[0;36m'$line'\033[0m'
                                while [ $wc1 == $wc2 ]
                                do
                                        printf '\007'
                                        wc1=`cat $currentfilename|wc -l`
                                        sleep 3
                                done
                        fi
                else
                        if [ $cri == 0 ]; then
                                echo $line
                        else
                                wc1=`cat $currentfilename|wc -l`
                                wc2=`cat $currentfilename|wc -l`
                                echo '\033[0;36m'$line'\033[0m'
                                while [ $wc1 == $wc2 ]
                                do
                                        printf '\007'
                                        wc1=`cat $currentfilename|wc -l`
                                        sleep 3
                                done
                        fi

                fi
		wc1=`cat $currentfilename|wc -l`
		sleep 2
		else
		currentfilename=`ls -lt DR_MONTHLY.log.* | head -1|awk '{print $9}'`
		sleep 2
	fi
done
}
logcheck 2> /dev/null
