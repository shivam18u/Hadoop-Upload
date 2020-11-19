#!/bin/bash

###Checking User as only hdfs user can upload files###
if [[ ! "$USER" = "hdfs" ]];then 
	echo "User does not have permission to upload files"
	echo "Logging in user hdfs"
	su hdfs
fi

###Checking if folder exists###
EXIST=`hdfs dfs -ls $2 | grep Found`

if [[ $EXIST  ]] ;then
	echo "Folder exists"
else
	echo "Folder doesn't exist"
	echo "Creating Folder"
	hdfs dfs -mkdir -p $2
fi

###comparing if files exist and ask for overwrite permission####

x=`ls $1`
y=`hdfs dfs -ls $2| tr -s " " | cut -d " " -f8`

for FILE in $x
do
	if [[ `echo $y | grep $FILE` ]];then
		echo "$FILE Already Exists in destination folder"
		read -p"Replace $FILE?(Y/N)" replace
		if [[ "$replace" = "Y" || "$replace" = "y" ]];then
			hdfs dfs -rm $2/$FILE
		fi
	fi
done

###uploading files###
hdfs dfs -put $1 $2;

hdfs dfs -ls $2;
