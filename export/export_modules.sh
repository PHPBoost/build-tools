#!/bin/bash

Path=$1
ExportPath=$2

cd $Path

for file in $(ls); 
do 
	if [ -e $file/config.ini ] ; 
	then zip -r $ExportPath$file.zip $file;
	echo $ExportPath${folders[i]}.zip created; 
	fi 
done

