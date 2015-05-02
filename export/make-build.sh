#!/bin/bash

# Functions
contains() { [[ $1 =~ (^|[[:space:]])"$2"($|[[:space:]]) ]] && return 0 || return 1; }

usage() { echo "Usage: $0 [-b <branch>] " 1>&2; exit 1; }

# Parameters

branchesList="3.0 4.0 4.1"
bflag=0
while getopts b:h name
  do
    case $name in
        b)
            bflag=1
            bval="$OPTARG"
            ;;
        h|?)
            usage
            ;;
    esac
done

if [ $bflag == 1 ] && ! $(contains "$branchesList" "$bval") ;
then echo 'branche incorrecte. Liste des branches : '$branchesList'.';
exit 1;
fi

if [ $bflag == 1 ] ;
then Branch=$bval;
else Branch='4.1';
fi

# Script beginning

scriptDir=$(pwd)
buildsDir='builds'
Export=$buildsDir'/phpboost_cache'
Export_full=$buildsDir'/phpboost'
Export_pdk=$buildsDir'/phpboost_pdk'
Original='phpboost'
repositoryPath='../..'
repositoryDir='phpboost-'$Branch

if [ ! -d $repositoryPath/$repositoryDir ] ;
then echo 'cloning repository'
cd $repositoryPath;
mkdir $repositoryDir;
hg clone https://code.google.com/p/phpboost/#$Branch $repositoryDir
cd $scriptDir;
fi

echo 'beginning building'
if [ -h $Original ] ;
then unlink $Original;
fi
ln -s $repositoryPath/$repositoryDir $Original

mkdir -p $buildsDir
rm -rf $Export

## Build version zip
build_version=$(cat $Original/kernel/.build)
#build_version=$((${build_version} + 1))
#echo $build_version > $Export'/kernel/.build'

if [ $build_version > 0 ] ;
then ./make-diff.sh phpboost-$Branch.$(($build_version - 1)) phpboost-$Branch.$build_version;
fi

echo 'copying files'
cp -r $Original/ $Export

## Nettoyage des dossiers
rm -rf $Export'/.hg'
rm -rf $Export'/.settings'
rm -rf $Export'/.hgignore'
rm -rf $Export'/.hgtags'
rm -rf $Export'/.project'
rm -rf $Export'/.htaccess'
rm -rf $Export'/test'
rm -rf $Export'/update'
rm -rf $Export'/HomePage'
rm -rf $Export'/server_migration.php'
rm -rf $Export'/todo.txt'
rm -rf $Export'/changelog.txt'
rm -rf $Export'/templates/phpboost'

## Htaccess
touch $Export/.htaccess

## CHMOD
chmod -R 777 $Export'/cache' $Export'/upload' $Export'/templates' $Export'/menus' $Export'/lang'  $Export'/images' $Export'/'


################################ Full pack ######################################

echo 'building Full pack'
rm -rf $Export_full
cp -r $Export/ $Export_full
rm -rf $Export_full'/bugtracker'
rm -rf $Export_full'/doc'
rm -rf $Export_full'/sandbox'
echo 'optimizing kernel'
java -jar bin/poptimizer.jar -i $Export_full/kernel -o $Export_full/optimized-kernel -e lib/ lib/php/geshi/ lib/php/mathpublisher/ -ics ISO-8859-1 -ocs ISO-8859-1 1>/dev/null
rm -rf $Export_full'/kernel'
mv $Export_full'/optimized-kernel' $Export_full'/kernel'

rm -rf $Export_full'/install/distribution.ini'
rm -rf $Export_full'/install/lang/french/distribution.php'
rm -rf $Export_full'/install/lang/english/distribution.php'
mv $Export_full'/install/distribution/distribution_full.ini' $Export_full'/install/distribution.ini'
mv $Export_full'/install/distribution/distribution_full_french.php' $Export_full'/install/lang/french/distribution.php'
mv $Export_full'/install/distribution/distribution_full_english.php' $Export_full'/install/lang/english/distribution.php'
rm -rf $Export_full'/install/distribution/'

################################ PDK pack ######################################

echo 'building PDK pack'
rm -rf $Export_pdk
cp -r $Export/ $Export_pdk
rm -rf $Export_pdk'/articles' $Export_pdk'/calendar' $Export_pdk'/contact' $Export_pdk'/online' $Export_pdk'/shoutbox' $Export_pdk'/faq' $Export_pdk'/forum' $Export_pdk'/gallery' $Export_pdk'/web' $Export_pdk'/guestbook' $Export_pdk'/ThemesSwitcher' $Export_pdk'/LangsSwitcher' $Export_pdk'/media' $Export_pdk'/news' $Export_pdk'/newsletter' $Export_pdk'/pages' $Export_pdk'/customization' $Export_pdk'/sitemap' $Export_pdk'/search' $Export_pdk'/poll' $Export_pdk'/stats' $Export_pdk'/download' $Export_pdk'/wiki'

rm -rf $Export_pdk'/install/distribution.ini'
rm -rf $Export_pdk'/install/lang/french/distribution.php'
rm -rf $Export_pdk'/install/lang/english/distribution.php'
mv $Export_pdk'/install/distribution/distribution_pdk.ini' $Export_pdk'/install/distribution.ini'
mv $Export_pdk'/install/distribution/distribution_pdk_french.php' $Export_pdk'/install/lang/french/distribution.php'
mv $Export_pdk'/install/distribution/distribution_pdk_english.php' $Export_pdk'/install/lang/english/distribution.php'
rm -rf $Export_full'/install/distribution/'

## Documentation
mkdir -p $Export_pdk'/doc/'$Branch
#cp -R /tmp/phpboost/doc/* $Export_pdk'/doc/4.0'

################################

## Export modules zip

echo 'building modules zip files'
cd $Export

rm -rf ../modules
mkdir -p ../modules

for folder in $(ls); 
do 
	if [ -e $folder/config.ini ] ; 
	then zip -r '../modules/'$folder'.zip' $folder 1>/dev/null;
	fi 
done

################################

## On se place dans le répertoire
cd ..

## Export to zip
zip -r 'phpboost.zip' phpboost/ 1>/dev/null
zip -r 'phpboost_pdk.zip' phpboost_pdk/ 1>/dev/null

cd $scriptDir
rm -rf $Export
unlink $Original
rm -rf 0

echo -e ''
echo 'zip files are created for PHPBoost '$Branch'.'$build_version

exit 0
