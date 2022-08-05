#!/bin/bash
joblist=$1
template=$2

W=0

:>cases.tmp


while read -r line;
do
    args=(${line//,/ })
    jobname=${args[0]}
    thiscase=${args[1]}
    setup=${args[2]}
    status=${args[3]}

    if [ $status = "queued" ]; then

	
	#run setup script if needed
	cd $thiscase
	if [ $setup != "none" ]; then
	    $setup
	fi
	
	#submit case, capturing job_id
	./case.submit --resubmit-immediate
	X=$(./xmlquery JOB_IDS)
	arrX=(${X//:/ })
	jobid=${arrX[-1]}
	
	#update job status to submitted
	cd -
 	echo $jobname","$thiscase","$setup",submitted">>cases.tmp
	
    elif [ $status = "waiting" ] && [ $W -eq 0 ];then
	((W++))
	#prepare next job for queue
	qj=$jobname".job"
	cp $template $qj
	sed -i 's:jobname:'$jobname':g' $qj
	sed -i 's:joblist:'$joblist':g' $qj
	sed -i 's:jobid:'$jobid':g' $qj

	#update job status to queued
	echo $jobname","$thiscase","$setup",queued">>cases.tmp
    else
	# job status unchanged
	echo $line>>cases.tmp
    fi

done < $joblist


mv cases.tmp $joblist

if [ $W -gt 0 ];then 
    #queue next job
    qsub $qj
fi
