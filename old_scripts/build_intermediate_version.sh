#!/bin/bash

Export='../../builds/phpboost'
Original='../../phpboost'

OldTypeBuild='a'
NewTypeBuild='a'
build_version='a3'

cp -r $Original/ $Export

echo 'copy phpboost folders success'

## Nettoyage des dossiers
rm -rf $Export'/.hg'
rm -rf $Export'/.settings'
rm $Export'/.hgignore'
rm $Export'/.hgtags'
rm $Export'/.project'
## rm -rf $Export'/bugtracker'
rm -rf $Export'/doc'
rm -rf $Export'/HomePage'
rm -rf $Export'/test'
rm -rf $Export'/sandbox'
rm -rf $Export'/todo.txt'
rm -rf $Export'/changelog.txt'
rm -rf $Export'/update'
rm -rf $Export'/templates/phpboost'

echo 'delete useless folders success'

## Build version zip
#i=`grep -Eo "$OldTypeBuild([0-9]+)" $Export'/kernel/.build' | cut -f2 -d$NewTypeBuild`
#build_version=$NewTypeBuild$((${i} + 1))
echo $build_version > $Export'/kernel/.build'

echo 'incremente build version success'

## change build version orignal
echo $build_version > $Original'/kernel/.build'

## Htaccess
touch $Export/.htaccess

## CHMOD
chmod -R 777 $Export'/cache' $Export'/upload' $Export'/template' $Export'/menus' $Export'/lang'  $Export'/images' $Export'/'

## On se place dans le répertoire
cd ../../builds/

## Export to zip
zip -r 'phpboost_'$build_version'.zip' phpboost/

echo 'zip are created in builds/phpboost_'$build_version'.zip'
