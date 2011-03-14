#!/bin/bash

old=$1
new=$2
cd $3
destination=`pwd`
repository=http://phpboost.googlecode.com/svn/tags
tmpDir=/tmp/phpboost-diff
diffFile=diff-$old-to-$new.zip
diffFileOptimized=diff-$old-to-$new-optimized.zip

cd $SVN_PATH/tags/
svn update $new && cd $new
rm -rf $tmpDir && mkdir $tmpDir

echo 'computing revision history'
echo "build non-optimized patch to $tmpDir/$diffFile"

for file in `svn diff --old="${repository}/${old}" --new="${repository}/${new}" --summarize | sed -e "s#[A-Z]\s*${repository}/${old}/##"`
do
        if [ -f $file ]; then
                if [[ ! $file =~ ^(install|update)/.+ ]]; then
                        zip $tmpDir/$diffFile $file
                fi
        fi
done

echo "copy non-optimized patch from  $tmpDir/$diffFile to $destination/$diffFile"
cp $tmpDir/$diffFile $destination/$diffFile


echo "optimize kernel patch"
cd $tmpDir && unzip $diffFile && rm -f $diffFile && mkdir kernel-optimized
java -jar $SVN_PATH/tools/POptimizer/poptimizer.jar --ics=iso-8859-1 --ocs=iso-8859-1 -i kernel -o kernel-optimized
rm -rf kernel && mv kernel-optimized kernel

echo "build optimized patch to $destination/$diffFileOptimized"
rm -f $destination/$diffFileOptimized
zip -r $destination/$diffFileOptimized *

