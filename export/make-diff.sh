#!/bin/bash

cd $(dirname $0) && here=$(pwd) && cd - > /dev/null
binDir=$here/../../bin/
repository=$1
old=$2
new=$3
tmpDir=/tmp/phpboost-diff
diffFile=diff-$old-to-$new.zip
diffFileOptimized=diff-$old-to-$new-optimized.zip

cd $4
destination=`pwd`
cd - > /dev/null

rm -rf $tmpDir && mkdir $tmpDir

echo 'computing revision history'

# computing modified files
cd $1
raw_diff_output=$(hg diff -r ${old}:${new} --stat)
lines_count=$(echo -e "$raw_diff_output" | wc -l)
changed_files=$(echo -e "$raw_diff_output" | head -n $((lines_count - 1)))
changed_files=$(echo -e "$changed_files" | sed -e "s#\s*|.*\$##")
echo -e "$changed_files"

hg up -c $new

echo "build non-optimized patch to $tmpDir/$diffFile"
for file in `echo $changed_files`
do
	echo $file
        if [ -f $file ]; then
                if [[ ! $file =~ ^(install|update)/.+ ]]; then
                        zip $tmpDir/$diffFile $file
                fi
        fi
done

cd - > /dev/null

echo "copy non-optimized patch from  $tmpDir/$diffFile to $destination/$diffFile"
cp $tmpDir/$diffFile $destination/$diffFile


echo "optimize kernel patch"
cd $tmpDir && unzip $diffFile && rm -f $diffFile && mkdir kernel-optimized
java -jar $binDir/poptimizer.jar --ics=iso-8859-1 --ocs=iso-8859-1 -i kernel -o kernel-optimized
rm -rf kernel && mv kernel-optimized kernel

echo "build optimized patch to $destination/$diffFileOptimized"
rm -f $destination/$diffFileOptimized
zip -r $destination/$diffFileOptimized *
