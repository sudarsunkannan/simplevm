#!/bin/bash
set -x


BENCHMARK="benchmark_thread"
# Benchmark to copy
BENCH=/home/sudarsun/ssd/$BENCHMARK
# Run C or CPP projects
PROC1RUN="timeout 15s ./pthread_test"
PROC2RUN="timeout 15s ./pthreadcpp"
RUNPATH=""
OUTPUT=out.txt

SUBMISSION_DIR=/home/sudarsun/ssd/Project_3_User_Level_Memory_Management
cd $SUBMISSION_DIR
iteratename=""

OUTPUTPATTERN1="1 1 1 1 1"
OUTPUTPATTERN2="15 15 15 15 15"
OUTPUTPATTERN1_COUNT=15
OUTPUTPATTERN2_COUNT=15


GETRESULT() {
	#Check for output match using our benchmark.
        # The thread benchmark performs 15 * 15 matrix multiplication using 25 threads
	match1=`grep -c -r $OUTPUTPATTERN1 $OUTPUT`
	match2=`grep -c -r $OUTPUTPATTERN2 $OUTPUT`

        # Number of output line match
	match1count=$OUTPUTPATTERN1_COUNT
	match2count=$OUTPUTPATTERN2_COUNT

	if [ "${match1}" = $match1count ] && [ "${match2}" = $match2count ]
	then 
		temp=`grep -c -r "pthread" ../*vm.c*`
		matches3=$temp

		if [ "${matches3}" != 0 ];
		then
			let matches4=0
			#echo $run
			temp=`grep -c -r "TLB" ../*vm.c*` 
			matches4=$temp
			if [ "${matches4}" != 0 ];
			then
				echo ${RUNPATH%/*/*} $match1 $match2 $matches3 $matches4
			else
				echo ${RUNPATH%/*/*} $match1 $match2 $matches3 0
			fi		
		else
			echo ${RUNPATH%/*/*} $match1 $match2 $matches3 0
		fi
	else
		echo ${RUNPATH%/*/*} 0 0 0 0
	fi
	match1=0
	match2=0
	matches4=0
}


#Some students have their code in  NAME/Submission_attachments/project3 or a similar directory
RUN_EXP() {
	for iteratename in */Submission_attachments
	do
		ls $iteratename/* >/dev/null 2>&1 ; 
		if [ $? != 0 ]; 
		then 
		  RUNPATH=$iteratename/"dummy"	
		  GETRESULT
		else
			for f in $iteratename/*; do
				if [ -d "$f" ]; then

					#The library code is present immediately within the project directory
					if [ ! -f "$f/my_vm.c" ]; then
						#The library code is present inside a
						#subdirectory code, so traverse to it.
						cd $f/code
					else
						cd $f
					fi
					RUNPATH=$f
					if [ -d "$BENCHMARK" ]; then
						cd $BENCHMARK
						rm $OUTPUT
						$PROC1RUN &> $OUTPUT
						$PROC2RUN &>> $OUTPUT
						GETRESULT
					elif [ -f "my_vm.c" ]; then 
						cp -r $BENCH .
						cd $BENCHMARK	
						rm $OUTPUT
						$PROC1RUN &> $OUTPUT
						$PROC2RUN &>> $OUTPUT
						GETRESULT
					fi
				fi
			done
			cd $SUBMISSION_DIR
		fi
	done
}



# We must also handle a condition where some students have not submitted the benchmark code, so 
COMPILE_BENCHMARK() {
	for iteratename in */Submission_attachments
	do
		MYPATH="$iteratename/*3*"

		for f in $iteratename/*; do
			if [ -d "$f" ]; then
				#The library code is present immediately within the project directory
				if [ ! -f "$f/my_vm.c" ]; then
					#The library code is present inside a
					#subdirectory code, so traverse to it.
					cd $f/code
				else 
					cd $f
				fi
				make clean &> $OUTPUT
				make &> $OUTPUT
				if [ -d "$BENCHMARK" ]; then
					cd $BENCHMARK
					rm test
					make clean &> $OUTPUT
					make &> $OUTPUT
				else
					# Student has not submitted the benchmark code, so copy`
					cp -r $BENCH .
					cd $BENCHMARK
					rm test
					make clean &> $OUTPUT
					make &> $OUTPUT
				fi
			fi
		done
		cd $SUBMISSION_DIR


	done
}

COMPILE_BENCHMARK
RUN_EXP
