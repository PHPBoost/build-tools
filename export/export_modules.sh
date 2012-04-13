#!/bin/bash

Path='../../phpboost/'
ExportPath='../build-tools/export/modules/'

cd $Path

for file in $(ls); 
do 
	if [ -e $file/lang/french/config.ini ] ; 
	then zip -r $ExportPath$file.zip $file;
	echo $ExportPath${folders[i]}.zip created; 
	fi 
done

