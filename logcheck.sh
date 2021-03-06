##version 2.1
#!/bin/ksh
logcheck(){
beep=0
cri=0
curfile=`ls -lt DR_MONTHLY.log.* | head -1|awk '{print $9}'`
tail -1 $curfile
wc1=`cat $curfile|wc -l`
trap trapInt 2
trap trapQuit 3
warcnt=0

trapQuit()
{
	
    if [[ `expr $cri % 2` == 0 ]]; then
		echo '\t\t\t\t\033[0;41m'Manual mode'\033[0m'
		cri=1
		beep=1
	elif [[ $cri == 1 ]] && [[ $beep == 0 ]]; then
		echo '\t\t\t\t\033[0;42m'Automatic mode'\033[0m'
		beep=0
		cri=0
	elif [[ $cri == 1 ]] && [[ $beep == 1 ]]; then
		echo '\t\t\t\t\033[0;42m'Automatic mode'\033[0m'
		cri=0
		beep=0
		break
	fi
}	

trapInt()
{
    if [[ $beep == 0 ]]; then
		echo "Do you want to close this program? yes | no ( y | n )"
        read answer
        case $answer in
            yes|Yes|y)
                exit;;
            no|n)
                continue;;
        esac
    elif [[ $beep == 1 ]]; then
		beep=0
		break
    fi
}

while true
do
	
	wc1=`cat $curfile|wc -l`
	wc2=`cat $curfile|wc -l`
	if [ $wc1 == $wc2 ]; then
		while [ $wc1 == $wc2 ]
		do
			curfile=`ls -lt DR_MONTHLY.log.* | head -1|awk '{print $9}'`
			wc1=`cat $curfile|wc -l`
			sleep 1
		done
	fi
	if [ $wc1 != $wc2 ]; then
		line=`tail -1 $curfile`
		#### AIX $8, LINUX $7
		linesc=`echo -e \'$line\'|awk '{print $8}'`
		if [[ "Critical." == $linesc ]] || [[ "Failure" == $linesc ]]; then
			warcnt=0
			cri=1
			beep=1
			wc2=$wc1
			echo '\033[0;41m\033[7m'$line'\033[0m'
			echo '\t\t\t\t\033[0;41m'Manual mode'\033[0m'
			while [ $beep == 1 ]
			do
				printf '\007'
				curfile=`ls -lt DR_MONTHLY.log.* | head -1|awk '{print $9}'`
                wc1=`cat $curfile|wc -l`
                sleep 3
				if [ $wc1 != $wc2 ]; then
					line=`tail -1 $curfile`
					echo '\033[0;36m'$line'\033[0m'
					break
				fi
			done
			
		elif [ "Warning" == "$linesc" ]; then
			if [ $cri == 1 ]; then
			beep=1
			wc2=$wc1
			echo '\033[0;36m'$line'\033[0m'
			while [ $beep == 1 ]
			do
				printf '\007'
                wc1=`cat $curfile|wc -l`
                sleep 3
				if [ $wc1 != $wc2 ]; then
					line=`tail -1 $curfile`
					echo '\033[0;36m'$line'\033[0m'
					break
				fi
			done
			else
				warcnt=`expr $warcnt + 1`
				echo warcnt $warcnt
				wc2=$wc1
				if [ $warcnt -ge 6 ]; then
					beep=1
					echo '\033[0;33m'$line'\033[0m'
					while [ $beep == 1 ]
					do
						printf '\007'
						wc1=`cat $curfile|wc -l`
						sleep 3
						if [ $wc1 != $wc2 ]; then
							line=`tail -1 $curfile`
							echo '\033[0;36m'$line'\033[0m'
							break
						fi
					done
				else
					echo '\033[0;33m'$line'\033[0m'
				fi
			fi
		else
			if [ $cri == 1 ]; then
			warcnt=0
			beep=1
			wc2=$wc1
			echo '\033[0;36m'$line'\033[0m'
			while [ $beep == 1 ]
			do
				printf '\007'
                wc1=`cat $curfile|wc -l`
                sleep 3
				if [ $wc1 != $wc2 ]; then
					line=`tail -1 $curfile`
					echo '\033[0;36m'$line'\033[0m'
					break
				fi
			done
			else
				warcnt=0
				echo $line
			fi
			
		fi
		
	fi
done
}
logcheck 2> /dev/null
