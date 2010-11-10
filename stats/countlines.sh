#!/bin/sh

if [ $# -eq 0 ]
then
	echo Error: please enter the path you want to explore
	echo The right syntax is countlines.sh path
fi

files=`find $1 -name "*.php"`
numLines=0
numFiles=`echo "$files" | wc -l`

for file in $files
do
	fileLines=`cat $file | wc -l`
	numLines=$(($numLines + $fileLines))
done

echo $numLines lines found in $numFiles files explored
echo Without file headers: $(($numLines - 26 * $numFiles)) lines
