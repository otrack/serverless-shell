#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/utils.sh

OLDIFS=$IFS
IFS="|"
input=($@)
#if [[ ${#input[@]} -eq 1 ]];
#then
#    exit 0
#fi

# AWS EFS
root=$(config "aws.efs.root")
pipes=()
patternskip1="rm_pash_fifos"
patternskip2="mkfifo_pash_fifos()"
patternskip3="rm -f"
patternskip4="mkfifo"
patternskip5="/pash/runtime/eager.sh"
patternskip6="/pash/runtime/auto-split.sh"
patternskip7="source"
patternskip8="&"

sshell="sshell"
inputbash="$1"
echo input: $inputbash
echo =======================================
#for i in ${input[@]};
while read line
do
    #matchpattern=$(echo $line | grep -q "$pattern1" || echo $line | grep -q "$pattern2" || echo $line | grep -q "$pattern3")
    matchpattern4=$(echo $line | grep -q "$pattern4")
    matchpattern3=$(echo $line | grep -q "$pattern3")
    if echo "$line" | grep -q "$patternskip1" || echo "$line" | grep -q "$patternskip3" || echo "$line" | grep -q "$patternskip4" || echo $line | grep -q "$patternskip5" || echo $line | grep -q "$patternskip6" || echo $line | grep -q "$patternskip7"; then
      	#echo HIT
      	continue
    fi
    #if [[ "$line" == *"fifo"* ]] ; then 
    #	echo FIFO
    #fi

    line=$(echo $line | sed 's/{//g')
    line=$(echo $line | sed 's/}//g')
    line=$(echo $line | sed 's/</< /g')
    line=$(echo $line | sed 's/>/> /g')

    #echo line: $line
    dumpline=""
    IFS=', ' read -r -a arrayline <<< "$line"
    for index in "${!arrayline[@]}"
    do
	#echo elem: ${arrayline[index]}
        if [[ "${arrayline[index]}" == *"tmp"* ]] ; then 
	        #echo fifo substring: ${arrayline[index]}
		tmparrayline="/mnt/efsimttsp/uuid"
		#arrayline[index]=$tmparrayline
		#tmparrayline=${arrayline[index]}
        	dumpline="${dumpline} ${tmparrayline}"
	else
        	dumpline="${dumpline} ${arrayline[index]}"
	fi
        #${tmparrayline//tmp/fs}	
	#echo tmp: $tmparrayline
    done
    #dumpline=$arrayline
    echo dumpline: $dumpline
    #echo After line replacement : ${line//tmp*/fs}
    #echo match pattern: $matchpattern
    #if [ -n "$matchpattern4" ]; then
    #  echo HIT
    #  continue
    #fi
    #echo ------------------
    #cmd=$(echo $i | sed 's/"/\\"/g')
    cmd=$(echo $line | sed 's/"/\\"/g')
    #echo CMD: $cmd
    if [[ $start == "1" ]];
    then
    	# AWS EFS
    	pipe=${root}"/"$(uuid)
    	# pipe=${root}"/test"
    	output+=" | awk '{print \\\$0}END{print \\\"EOF\\\"}' > "${pipe}"\" &\n"
    	output+=${sshell}
    	if [[ ${cmd} != ${input[-1]} ]];
    	then
    	    output+="" # --async FIXME
    	fi
    	output+=" \"tail -n +0 --pid=\\$\\$ -f --retry "${pipe}" 2>/dev/null | { sed \\\"/EOF/ q\\\" && kill \\$\\$ ;} | grep -v ^EOF\\$ | "${cmd}
    	pipes+=(${pipe})
    else
    	start="1"
    	output+=${sshell}" \""${cmd} # --async 
    fi
done < $input
#done
output+="\""
for p in ${pipes[@]}
do
    output+="\n"${sshell}" \"rm -f "${p}"\" &"
done
output+="\nwait"
IFS=$OLDIFS
#echo -e  ${output}
