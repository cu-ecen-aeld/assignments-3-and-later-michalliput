#!/bin/sh
# Assignment 1 script: Writer
# Author: Michal Liput

FULLFILEPATH=$1
FILECONTENT=$2

if [ $# -lt 2 ]
then
	echo "Writer failed: 2 parameters are required"
	exit 1
else
	
	#echo "Your file path is ${FULLFILEPATH}"
	#echo "Your file content is ${FILECONTENT}"
	mkdir -p $(dirname ${FULLFILEPATH}) && touch ${FULLFILEPATH}
	if [ ! -f ${FULLFILEPATH} ]
	then
		echo "Writer failed: file creation error"
		exit 1
	else
		echo ${FILECONTENT} > ${FULLFILEPATH}
		exit 0
	fi
fi
