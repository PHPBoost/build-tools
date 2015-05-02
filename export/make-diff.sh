#!/bin/bash

scriptDir=$(pwd)
repository='phpboost'
oldTag=$1
newTag=$2
diffFile=diff-$oldTag-to-$newTag.zip
diffFileOptimized=diff-$oldTag-to-$newTag-optimized.zip
diffCmd='hg diff'
destination='builds'
tmpDir='/tmp/phpboost-diff'

mkdir -p $destination
rm -rf $tmpDir && mkdir $tmpDir

echo 'building incremental zip files'

# computing modified files
cd $repository
raw_diff_output=$($diffCmd -r ${oldTag}:${newTag} --stat)
lines_count=$(echo -e "$raw_diff_output" | wc -l)
changed_files=$(echo -e "$raw_diff_output" | head -n $((lines_count - 1)))
changed_files=$(echo -e "$changed_files" | sed -e "s#\s*|.*\$##"  | grep -v '.hgtags')
echo -e "
Modified files list :
$changed_files
"

hg update -c $newTag 1>/dev/null

echo "building non-optimized patch to $tmpDir/$diffFile"
for file in `echo $changed_files`
do
        if [ -f $file ]; then
                if [[ ! $file =~ ^(install|update)/.+ ]]; then
                        zip $tmpDir/$diffFile $file 1>/dev/null
                fi
        fi
done

echo "copying non-optimized patch from  $tmpDir/$diffFile to $scriptDir/$destination/$diffFile"
cp $tmpDir/$diffFile $scriptDir/$destination/$diffFile

echo "optimizing kernel patch"
cd $tmpDir && unzip $diffFile 1>/dev/null && rm -f $diffFile && mkdir kernel-optimized
java -jar $scriptDir/bin/poptimizer.jar --ics=iso-8859-1 --ocs=iso-8859-1 -i kernel -o kernel-optimized 1>/dev/null
rm -rf kernel && mv kernel-optimized kernel

echo "building optimized patch to $scriptDir/$destination/$diffFileOptimized"
rm -f $scriptDir/$destination/$diffFileOptimized
zip -r $scriptDir/$destination/$diffFileOptimized * 1>/dev/null

cp -r $tmpDir $scriptDir/$destination
rm -rf $tmpDir

echo 'incremental build version success'
echo -e '';

exit 0

