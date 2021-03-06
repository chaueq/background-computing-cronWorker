#!/bin/bash
command="xmr-stak"
launcher="mine-xmr"
logFile="/opt/xmr-stak/log.txt"
maxCPU="40" #maximum percentage of ALL computing power used by other programs
maxLogSize="10485760" #in bytes | 10MB by default
switchFile="/opt/xmr-stak/mine.switch"

function getCPUusage()
{
	str=$(ps -Ao pcpu,comm --sort=-pcpu | grep " 0.0" -v | grep "$command" -v | tail -n +2)
	str=$(echo $str)
	re="^[0-9]+([.][0-9]+)?$"
	sum=0.0
	IFS=' ' # space is set as delimiter
	read -ra ADDR <<< "$str" # str is read into an array as tokens separated by IFS
	for i in "${ADDR[@]}"; do # access each element of array
		if [[ "$i" =~ $re ]]; then
			sum=$(bc <<< "$sum + $i")
		fi
	done
	echo -n $sum
}

threads=$(nproc)
maxCPU=$(echo "$maxCPU * $threads" | bc)
list=$(ps -ae | grep $command)
ac_adapter=$(acpi -a | cut -d' ' -f3 | cut -d- -f1)
usage=$(getCPUusage)
hasPower=$(echo "$usage <= $maxCPU" | bc)
switchState=$(cat $switchFile)

if [ "$ac_adapter" = "on" ]; then
	if [ "$hasPower" = "1" ]; then
		if [ "$switchState" = "1" ]; then
			if [ -z "$list" ]; then
				$launcher > $logFile &
			fi
		else
			if [ -n "$list" ]; then
				killall $command
			fi
		fi
	else
		if [ -n "$list" ]; then
			killall $command
		fi
	fi
else
	if [ -n "$list" ]; then
		killall $command
	fi
fi

logLen=$(ls -l $logFile | cut -d' ' -f5)
notEnoughSpace=$(echo "$logLen > $maxLogSize" | bc)

if [ "$notEnoughSpace" = "1" ]; then
	logContext=$(tail $logFile)	
	rm $logFile
	echo "$logContext" > $logFile
fi

