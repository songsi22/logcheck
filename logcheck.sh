if [ "$#" -lt 1 ]; then
        cri=0
elif [ "$1" -eq 1 ]; then
        cri=1
else
        print "if you want to manual mode."
        print "sh $0 1"
fi
logcheck(){
curfile=`ls -lt DR_MONTHLY.log.* | head -1|awk '{print $9}'`
tail -1 $curfile
wc1=`cat $curfile|wc -l`
#trap break 2
#trap 'echo "\033[0;31mmanual mode to automatic mode\033[0m";cri=0;rm -rf core;break' 3
trap trapInt 2
trap trapQuit 3
ctrlc_count_quit=0
ctrlc_count_int=0
beep=0
trapQuit()
{
    let ctrlc_count_quit++
    if [[ `expr $cri % 2` == 0 ]]; then
		echo "Manual mode"
		cri=1
	elif [[ $beep == 1 ]] && [[ `expr $cri % 2` == 1 ]]; then
		echo "Automatic mode"
		beep=0
		cri=0
		break
	else
		echo "Automatic mode"
		beep=0
		cri=0
	fi
}	
trapInt()
{
        let ctrlc_count_int++
    if [[ $beep == 0 ]]; then
		echo "Do you want to close this program? yes | no ( y | n )"
                read answer
                case $answer in
                                yes|Yes|y)
                                                exit
                                                ;;
                                no|n)
												ctrlc_count_int=0
                                                continue
                                                ;;
                esac
                ctrlc_count_int=0
    elif [[ $beep == 1 ]]; then
		beep=0
		break
    fi
}
while true
do

        wc2=`cat $curfile|wc -l`
        if [ $wc1 != $wc2 ]; then
                line=`tail -1 $curfile`
                linesc=`echo -e \'$line\'|awk '{print $6}'`

                if [[ "Critical." == $linesc ]] || [[ "Failure" == $linesc ]]; then
                        cri=1
                        echo '\033[0;41m\033[7m'$line'\033[0m'
                        wcc1=`cat $curfile|wc -l`
                        wcc2=`cat $curfile|wc -l`
                        while [ $wcc1 == $wcc2 ]
                        do
								beep=1
                                printf '\007'
                                wcc1=`cat $curfile|wc -l`
                                sleep 3
							
                        done

                elif [ "Warning" == "$linesc" ]; then
                        if [ $cri == 0 ]; then
                                echo '\033[0;33m'$line'\033[0m'
                        else
                                wcc1=`cat $curfile|wc -l`
                                wcc2=`cat $curfile|wc -l`
                                echo '\033[0;36m'$line'\033[0m'
                                while [ $wcc1 == $wcc2 ]
                                do
										beep=1
                                        printf '\007'
                                        wcc1=`cat $curfile|wc -l`
                                        sleep 3
                                done

                        fi
                else
                        if [ $cri == 0 ]; then
                                echo $line
                        else
                                wcc1=`cat $curfile|wc -l`
                                wcc2=`cat $curfile|wc -l`
                                echo '\033[0;36m'$line'\033[0m'
                                while [ $wcc1 == $wcc2 ]
                                do
										beep=1
                                        printf '\007'
                                        wcc1=`cat $curfile|wc -l`
                                        sleep 3
                                done
                        fi

                fi
                wc1=`cat $curfile|wc -l`
                sleep 2
                else
                curfile=`ls -lt DR_MONTHLY.log.* | head -1|awk '{print $9}'`
                sleep 2
        fi
done
}
logcheck 2> /dev/null
