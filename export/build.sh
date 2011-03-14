#!/bin/bash
directory=`pwd`
tmpPath='/tmp/phpboost' && mkdir ${tmpPath} 2> /dev/null
tmpExportPath=${tmpPath}'/export' && rm -rf ${tmpExportPath} && mkdir ${tmpExportPath}

cd ${1} && source=`pwd`
cd ${directory} && cd ${2} && destination=`pwd`
cd ${directory}

## Build number
declare -i i
cd ${source}
hg revert kernel/.build
cd -
i=`cat ${source}/kernel/.build`
echo $((${i} + 1)) > ${source}'/kernel/.build'

## Export
exported=${tmpExportPath}'/build'
echo 'Extracting repository'
cp -r ${source} ${exported} > /dev/null
rm -rf ${exported}/.hg
cd ${exported} && exported=`pwd` && cd ${directory}

## Deleting all the files which are useless
rm -rf ${exported}'/blog'
rm -rf ${exported}'/panel'
rm -rf ${exported}'/test'
rm -rf ${exported}'/todo.txt'
rm -rf ${exported}'/changelog.txt'
rm -rf ${exported}'/update'
rm -rf ${exported}'/sitemap'
rm -rf ${exported}'/templates/base2'
rm -rf ${exported}'/templates/theme1'
rm -rf ${exported}'/templates/vz3'
rm -rf ${exported}'/templates/phpboost'
mkdir ${exported}'/upload' ${exported}'/cache/tpl' ${exported}'/cache/syndication' ${exported}'/connect/db' ${exported}'/database/db' ${exported}'/images/avatar' ${exported}'/images/maths'
chmod -R 777 ${exported}'/cache' ${exported}'/upload' ${exported}'/download/'
touch $exported/.htaccess

## Generating the documentation before optimizing the files
echo 'Generating documentation'
$directory/doc.sh ${exported} > /dev/null

## Optimization
echo 'Optimizing kernel code'
mkdir ${exported}'/optimized-kernel'
toolsDir=${directory}/../../bin/
java -jar ${toolsDir}poptimizer.jar -i ${exported}/kernel -o ${exported}/optimized-kernel -e framework/lib/ framework/content/geshi/ framework/content/math/ -ics ISO-8859-1 -ocs ISO-8859-1

# Publication
echo 'Exporting publication distribution'
pub_dir=${exported}/../publication && mkdir ${pub_dir} && cd ${pub_dir} && pub_dir=`pwd` && cd ${directory}
cp -R ${exported}/* ${pub_dir}
cd ${pub_dir}
rm -rf calendar download faq forum gallery media newsletter online poll shoutbox stats wiki doc
rm -rf menus/themeswitcher
rm -rf templates/base templates/extends
rm -rf kernel && mv optimized-kernel kernel
cd install/distribution && rm -f community.png distribution_french.php distribution_community_english.php distribution_community_french.php distribution_english.php distribution_pdk_english.php distribution_pdk_french.php
mv distribution_publication_french.php distribution_french.php
mv distribution_publication_english.php distribution_english.php
cd ../../
ln -s ${pub_dir} ../phpboost
cd ../
rm -f ${destination}'/phpboost-publication.zip'
zip -r ${destination}'/phpboost-publication.zip' phpboost > /dev/null
rm phpboost

cd ${directory}

# Community
echo 'Exporting community distribution'
com_dir=${exported}/../community && mkdir ${com_dir} && cd ${com_dir} && com_dir=`pwd` && cd ${directory}
cp -R ${exported}/* ${com_dir}
cd ${com_dir}
rm -rf calendar media newsletter stats gallery doc
rm -rf menus/themeswitcher
rm -rf templates/base templates/publishing
rm -rf kernel && mv optimized-kernel kernel
cd install/distribution && rm -f publication.png distribution_french.php distribution_publication_english.php distribution_publication_french.php distribution_english.php distribution_pdk_english.php distribution_pdk_french.php
mv distribution_community_french.php distribution_french.php
mv distribution_community_english.php distribution_english.php
cd ../../
ln -s ${com_dir} ../phpboost
cd ../
rm -f ${destination}'/phpboost-community.zip'
zip -r ${destination}'/phpboost-community.zip' phpboost > /dev/null
rm phpboost

cd ${directory}

# PDK
echo 'Exporting PDK distribution'
pdk_dir=${exported}/../pdk && mkdir ${pdk_dir} && cd ${pdk_dir} && pdk_dir=`pwd` && cd ${directory}
cp -R ${exported}/* ${pdk_dir}
cd ${pdk_dir}
rm -rf optimized-kernel
rm -rf faq forum guestbook news pages search wiki articles contact download gallery menus/themeswitcher online poll shoutbox web newsletter media stats calendar
rm -rf templates/publishing
mkdir doc/3.0
cp -R /tmp/phpboost/doc/* doc/3.0
cd install/distribution && rm -f publication.png community.png distribution_french.php distribution_publication_english.php distribution_publication_french.php distribution_english.php distribution_community_english.php distribution_community_french.php
mv distribution_pdk_french.php distribution_french.php
mv distribution_pdk_english.php distribution_english.php
cd ../../
ln -s ${pdk_dir} ../phpboost
cd ../
rm -f ${destination}'/phpboost-pdk.zip'
zip -r ${destination}'/phpboost-pdk.zip' phpboost > /dev/null
rm phpboost

cd ${directory}

## Full
echo 'Exporting full distribution'
full_dir=${exported}/../full && mkdir ${full_dir} && cd ${full_dir} && full_dir=`pwd` && cd ${directory}
cp -R ${exported}/* ${full_dir}
cd ${full_dir}
rm -rf templates/extends templates/publishing
rm -rf kernel && mv optimized-kernel kernel
rm -rf doc
cd install/distribution && rm -f publication.png community.png distribution_publication_english.php distribution_publication_french.php distribution_community_english.php distribution_community_french.php distribution_pdk_english.php distribution_pdk_french.php
cd ../../
ln -s ${full_dir} ../phpboost
cd ../
rm -f ${destination}'/phpboost-full.zip'
zip -r ${destination}'/phpboost-full.zip' phpboost > /dev/null
rm phpboost

cd ${directory}
rm -rf ../phpboost/*
