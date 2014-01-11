#!/bin/bash

### Script dossier www
### Dossier phpboost dans www avec branche 4.0
### Dossier builds pour stocker les zips
### Dossier build-tools avec la branche build-tools
###


Export='builds/phpboost_cache'
Export_full='builds/phpboost'
Export_pdk='builds/phpboost_pdk'
Original='phpboost'

OldTypeBuild=''
NewTypeBuild=''

cp -r $Original/ $Export

echo 'copy phpboost folders success'

## Nettoyage des dossiers
rm -rf $Export'/.hg'
rm -rf $Export'/.settings'
rm $Export'/.hgignore'
rm $Export'/.hgtags'
rm $Export'/.project'
rm -rf $Export'/.htaccess'
rm -rf $Export'/test'
rm -rf $Export'/update'
rm -rf $Export'/HomePage'
rm -rf $Export'/server_migration.php'
rm -rf $Export'/todo.txt'
rm -rf $Export'/changelog.txt'
rm -rf $Export'/templates/phpboost'

echo 'delete useless folders success'

## Build version zip
build_version=`cat $Export/kernel/.build`
#build_version=$((${build_version} + 1))
echo $build_version > $Export'/kernel/.build'


echo 'incremente build version success : 4.0.'$build_version

## Htaccess
touch $Export/.htaccess

## CHMOD
chmod -R 777 $Export'/cache' $Export'/upload' $Export'/templates' $Export'/menus' $Export'/lang'  $Export'/images' $Export'/'




################################ Full pack ######################################

cp -r $Export/ $Export_full
rm -rf $Export_full'/bugtracker'
rm -rf $Export_full'/doc'
rm -rf $Export_full'/sandbox'
java -jar bin/poptimizer.jar -i $Export_full/kernel -o $Export_full/optimized-kernel -e lib/ lib/php/geshi/ lib/php/mathpublisher/ -ics ISO-8859-1 -ocs ISO-8859-1
rm -rf $Export_full'/kernel'
mv $Export_full'/optimized-kernel' $Export_full'/kernel'

rm $Export_full'/install/distribution.ini'
rm $Export_full'/install/lang/french/distribution.php'
rm $Export_full'/install/lang/english/distribution.php'
mv $Export_full'/install/distribution/distribution_full.ini' $Export_full'/install/distribution.ini'
mv $Export_full'/install/distribution/distribution_full_french.php' $Export_full'/install/lang/french/distribution.php'
mv $Export_full'/install/distribution/distribution_full_english.php' $Export_full'/install/lang/english/distribution.php'
rm -rf $Export_full'/install/distribution/'

################################ PDK pack ######################################

cp -r $Export/ $Export_pdk
rm -rf $Export_pdk'/articles' $Export_pdk'/calendar' $Export_pdk'/contact' $Export_pdk'/online' $Export_pdk'/shoutbox' $Export_pdk'/faq' $Export_pdk'/forum' $Export_pdk'/gallery' $Export_pdk'/web' $Export_pdk'/guestbook' $Export_pdk'/ThemesSwitcher' $Export_pdk'/LangsSwitcher' $Export_pdk'/media' $Export_pdk'/news' $Export_pdk'/newsletter' $Export_pdk'/pages' $Export_pdk'/customization' $Export_pdk'/sitemap' $Export_pdk'/search' $Export_pdk'/poll' $Export_pdk'/stats' $Export_pdk'/download' $Export_pdk'/wiki'

rm $Export_pdk'/install/distribution.ini'
rm $Export_pdk'/install/lang/french/distribution.php'
rm $Export_pdk'/install/lang/english/distribution.php'
mv $Export_pdk'/install/distribution/distribution_pdk.ini' $Export_pdk'/install/distribution.ini'
mv $Export_pdk'/install/distribution/distribution_pdk_french.php' $Export_pdk'/install/lang/french/distribution.php'
mv $Export_pdk'/install/distribution/distribution_pdk_english.php' $Export_pdk'/install/lang/english/distribution.php'
rm -rf $Export_full'/install/distribution/'

## Documentation
mkdir $Export_pdk'/doc/4.0'
cp -R /tmp/phpboost/doc/* $Export_pdk'/doc/4.0'

################################

## Export modules zip

cd $Export

rm -rf ../modules
mkdir ../modules

for folder in $(ls); 
do 
	if [ -e $folder/config.ini ] ; 
	then zip -r '../modules/'$folder'.zip' $folder;
	fi 
done

################################

## On se place dans le répertoire
cd ..

## Export to zip
zip -r 'phpboost.zip' phpboost/
zip -r 'phpboost_pdk.zip' phpboost_pdk/


echo 'zip are created for PHPBoost 4.0.'$build_version
