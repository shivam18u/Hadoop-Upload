#!/bin/bash
###INSTRUCTIONS####
####    ./upload.sh {path of source folder} {path of destination folder}
###################
dest=`echo ${2%/}`
src=$1
###Checking User as only hdfs user can upload files###
if [[ ! "$USER" = "hdfs" ]];then 
	echo "User does not have permission to upload files"
	echo "Logging in user hdfs"
	su hdfs -c $0 $src $dest
fi

###Checking if folder exists###
EXIST=`hdfs dfs -ls $dest | grep Found`

if [[ $EXIST  ]] ;then
	echo "Folder exists"
else
	echo "Folder doesn't exist"
	echo "Creating Folder"
	hdfs dfs -mkdir -p $dest
fi

###comparing if files exist and ask for overwrite permission####

x=`ls $src`
y=`hdfs dfs -ls $dest| tr -s " " | cut -d " " -f8`

for FILE in $x
do
	if [[ `echo $y | grep $FILE` ]];then
		echo "$FILE Already Exists in destination folder"
		read -p"Replace $FILE?(Y/N)" replace
		if [[ "$replace" = "Y" || "$replace" = "y" ]];then
			hdfs dfs -rm $dest/$FILE
		fi
	fi
done

###uploading files###
hdfs dfs -put $src $dest;

hdfs dfs -ls $dest;
