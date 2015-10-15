#!/bin/bash

scriptDir=$(pwd)
repository='phpboost'
oldTag=$1
newTag=$2
diffFile=diff-$oldTag-to-$newTag.zip
diffFileOptimized=diff-$oldTag-to-$newTag-optimized.zip
destination='export/diff'
tmpDir='/tmp/phpboost-diff'
versionControlUtil='git'

if [ -n $3 ] ;
then Branch=$3;
else Branch='4.1';
fi

mkdir -p $destination
rm -rf $tmpDir && mkdir $tmpDir

echo 'building incremental zip files'

# computing modified files
cd $repository
raw_diff_output=$($versionControlUtil diff --stat  --stat-name-width=200 --stat-width=200 ${oldTag} ${newTag})
lines_count=$(echo -e "$raw_diff_output" | wc -l)
changed_files=$(echo -e "$raw_diff_output" | head -n $((lines_count - 1)))
changed_files=$(echo -e "$changed_files" | sed -e "s#\s*|.*\$##")
echo -e "
Modified files list :
$changed_files
"

$versionControlUtil checkout tags/$newTag 1>/dev/null

echo "building non-optimized patch to $tmpDir/$diffFile"
for file in `echo $changed_files`
do
	if [ -f $file ]; then
		if [[ ! $file =~ ^(install|update|bugtracker|templates/phpboost|.gitignore|.git|.settings|.project|test|sandbox|HomePage|repository|server_migration.php|todo.txt|changelog.txt|README.md)/.+ ]]; then
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

echo 'minifying js files'
js_files_list=$(find . -iname '*.js');
for file in $js_files_list
do
bin/yc $file -o $file &>/dev/null
done

echo "building optimized patch to $scriptDir/$destination/$diffFileOptimized"
rm -f $scriptDir/$destination/$diffFileOptimized
zip -r $scriptDir/$destination/$diffFileOptimized * 1>/dev/null

rm -rf $scriptDir/builds/phpboost-diff
cp -r $tmpDir $scriptDir/builds
rm -rf $tmpDir

cd $scriptDir/$repository
$versionControlUtil checkout $Branch 1>/dev/null

echo 'incremental version build success'
echo -e '';

exit 0
