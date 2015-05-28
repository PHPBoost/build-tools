#!/bin/bash

# Functions
contains() { [[ $1 =~ (^|[[:space:]])"$2"($|[[:space:]]) ]] && return 0 || return 1; }

usage() { echo "Usage: $0 [-b <branch>] [-t]" 1>&2; exit 1; }

# Parameters

branchesList="3.0 4.0 4.1"
bflag=0
while getopts b:ht name
  do
    case $name in
        b)
            bflag=1
            bval="$OPTARG"
            ;;
        t)
            tflag=1
            ;;
        h|?)
            usage
            ;;
    esac
done

if [ $bflag == 1 ] && ! $(contains "$branchesList" "$bval") ;
then echo 'Incorrect branch. Branches list : '$branchesList'.';
exit 1;
fi

if [ $bflag == 1 ] ;
then Branch=$bval;
else Branch='4.1';
fi

# Script beginning

scriptDir=$(pwd)
buildsDir='builds/'
Build=$buildsDir'/phpboost_cache'
Build_full=$buildsDir'/phpboost'
Build_pdk=$buildsDir'/phpboost_pdk'
exportDir='export'/$Branch
Original='phpboost'
versionControlUtil='git'
remoteRepositoryUrl='https://github.com/PHPBoost/PHPBoost.git'
localRepositoryPath='..'
localRepositoryDir='phpboost-'$Branch

if [ ! -d $localRepositoryPath/$localRepositoryDir ] ;
then echo 'cloning repository'
cd $localRepositoryPath;
mkdir $localRepositoryDir;
$versionControlUtil clone --branch $Branch $remoteRepositoryUrl $localRepositoryDir
cd $scriptDir;
fi

echo 'beginning building'
if [ -h $Original ] ;
then unlink $Original;
fi
ln -s $localRepositoryPath/$localRepositoryDir $Original

mkdir -p $buildsDir
rm -rf $Build

## Build version zip
build_version=$(cat $Original/kernel/.build)
#build_version=$((${build_version} + 1))
#echo $build_version > $Export'/kernel/.build'

mkdir -p $exportDir/diff

if [ $build_version > 0 ] ;
then ./make-diff.sh phpboost-$Branch.$(($build_version - 1)) phpboost-$Branch.$build_version $Branch;
cp export/diff/* $exportDir/diff/
rm -rf export/diff/
fi

echo 'copying files'
cp -r $Original/ $Build

## Nettoyage des dossiers
rm -rf $Build'/.gitignore' $Build'/.git' $Build'/.settings' $Build'/.project' $Build'/.htaccess' $Build'/test' $Build'/update' $Build'/HomePage' $Build'/server_migration.php' $Build'/todo.txt' $Build'/changelog.txt' $Build'/templates/phpboost' $Build'/README.md'

## Htaccess
touch $Build/.htaccess

## CHMOD
chmod -R 777 $Build'/cache' $Build'/upload' $Build'/templates' $Build'/menus' $Build'/lang'  $Build'/images' $Build'/'


################################ Full pack ######################################

echo 'building Full pack'
rm -rf $Build_full
cp -r $Build/ $Build_full
rm -rf $Build_full'/bugtracker'
rm -rf $Build_full'/doc'
rm -rf $Build_full'/sandbox'
echo 'optimizing kernel'
java -jar bin/poptimizer.jar -i $Build_full/kernel -o $Build_full/optimized-kernel -e lib/ lib/php/geshi/ lib/php/mathpublisher/ -ics ISO-8859-1 -ocs ISO-8859-1 1>/dev/null
rm -rf $Build_full'/kernel'
mv $Build_full'/optimized-kernel' $Build_full'/kernel'

rm -rf $Build_full'/install/distribution.ini'
rm -rf $Build_full'/install/lang/french/distribution.php'
rm -rf $Build_full'/install/lang/english/distribution.php'
mv $Build_full'/install/distribution/distribution_full.ini' $Build_full'/install/distribution.ini'
mv $Build_full'/install/distribution/distribution_full_french.php' $Build_full'/install/lang/french/distribution.php'
mv $Build_full'/install/distribution/distribution_full_english.php' $Build_full'/install/lang/english/distribution.php'
rm -rf $Build_full'/install/distribution/'

################################ PDK pack ######################################

echo 'building PDK pack'
rm -rf $Build_pdk
cp -r $Build/ $Build_pdk
rm -rf $Build_pdk'/articles' $Build_pdk'/calendar' $Build_pdk'/contact' $Build_pdk'/online' $Build_pdk'/shoutbox' $Build_pdk'/faq' $Build_pdk'/forum' $Build_pdk'/gallery' $Build_pdk'/web' $Build_pdk'/guestbook' $Build_pdk'/ThemesSwitcher' $Build_pdk'/LangsSwitcher' $Build_pdk'/media' $Build_pdk'/news' $Build_pdk'/newsletter' $Build_pdk'/pages' $Build_pdk'/customization' $Build_pdk'/sitemap' $Build_pdk'/search' $Build_pdk'/poll' $Build_pdk'/stats' $Build_pdk'/download' $Build_pdk'/wiki'

rm -rf $Build_pdk'/install/distribution.ini'
rm -rf $Build_pdk'/install/lang/french/distribution.php'
rm -rf $Build_pdk'/install/lang/english/distribution.php'
mv $Build_pdk'/install/distribution/distribution_pdk.ini' $Build_pdk'/install/distribution.ini'
mv $Build_pdk'/install/distribution/distribution_pdk_french.php' $Build_pdk'/install/lang/french/distribution.php'
mv $Build_pdk'/install/distribution/distribution_pdk_english.php' $Build_pdk'/install/lang/english/distribution.php'
rm -rf $Build_pdk'/install/distribution/'

## Documentation
#mkdir -p $Build_pdk'/doc/'$Branch
#cp -R /tmp/phpboost/doc/* $Export_pdk'/doc/4.0'

################################

## Export modules zip

echo 'building modules zip files'
cd $Build

rm -rf $scriptDir/$exportDir/modules
mkdir -p $scriptDir/$exportDir/modules

for folder in $(ls); 
do 
	if [ -e $folder/config.ini ] ; 
	then zip -r $scriptDir/$exportDir/modules/$folder.zip $folder 1>/dev/null;
	fi
done

################################

## On se place dans le répertoire
cd $scriptDir

## Export to zip
mkdir -p $exportDir/phpboost
cd $Build/
zip -r $scriptDir/$exportDir/phpboost/phpboost.zip phpboost/ 1>/dev/null
zip -r $scriptDir/$exportDir/phpboost/phpboost_pdk.zip phpboost_pdk/ 1>/dev/null

cd $scriptDir
rm -rf $Build
unlink $Original
rm -rf 0

echo -e ''
echo 'zip files are created for PHPBoost '$Branch'.'$build_version

exit 0
