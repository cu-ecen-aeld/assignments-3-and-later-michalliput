#!/bin/sh
# Assignment 1 script: Finder
# Author: Michal Liput

FILESDIR=$1
SEARCHSTR=$2
count_files=0
count_found=0

if [ $# -lt 2 ]
then
	echo "Finder failed: 2 parameters are required"
	exit 1
else
	if [ -d ${FILESDIR} ]
	then
		#echo "Your base path is ${FILESDIR}"
		#echo "Your string to find is ${SEARCHSTR}"
		# Recursively find all the files under the base path
		count_files=$(find ${FILESDIR}* -type f | wc -l)
		# Recursively find all the lines with matching pattern in files under the base path and count new lines of output
		#count_found=$((grep ${SEARCHSTR} ${FILESDIR}* | wc -l)
		count_found=$(grep -r ${SEARCHSTR} ${FILESDIR}* | wc -l)
		echo "The number of files are ${count_files} and the number of matching lines are ${count_found}"
		exit 0
	else
		echo "Finder failed: directory doesn't exist"
		exit 1
	fi
fi
