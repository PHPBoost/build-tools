#!/bin/bash

# Functions
contains() { [[ $1 =~ (^|[[:space:]])"$2"($|[[:space:]]) ]] && return 0 || return 1; }

usage() { echo "Usage: $0 [-b <branch>] [-s <special version for the trunk. a1 to create alpha 1 for instance>]" 1>&2; exit 1; }

get_branches_list() {
	scriptDir=$(pwd)
	if [ -d $scriptDir/../trunk ] ;
	then
		cd $scriptDir/../trunk
		git pull 1>&2>/dev/null
		branchesList=$(git branch -r | grep -v 'HEAD' | grep -v 'master' | grep -v 'default' | grep -v 'standby$' | cut -d '/' -f 2 | xargs)
		cd $scriptDir
	else
		branchesList="5.0"
	fi
	echo $branchesList
}

# Parameters

branchesList=$(get_branches_list)
bflag=0
sflag=0
while getopts b:hs: name
 do
	case $name in
		b)
			bflag=1
			bval="$OPTARG"
			;;
		s)
			sflag=1
			sval="$OPTARG"
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
else Branch=$(echo $branchesList  | awk '{print $NF}');
fi

if [ $sflag == 1 ] ;
then
Branch='master'
bflag=0
localRepositoryDir='trunk';
else
localRepositoryDir='phpboost-'$Branch;
fi

# Script beginning

scriptDir=$(pwd)
buildsDir=$scriptDir'/builds'
Build=$buildsDir'/phpboost_cache'
Build_full=$buildsDir'/phpboost'
Build_update=$buildsDir'/phpboost_update'
Build_pdk=$buildsDir'/phpboost_pdk'
exportDir='export'/$Branch
Original='phpboost'
remoteRepositoryUrl='https://github.com/PHPBoost/PHPBoost.git'
localRepositoryPath='..'

previousMajorVersion=''
branchesArray=(${branchesList// / })
for i in "${!branchesArray[@]}"
do
	if [ ${branchesArray[i]} == $Branch ] && [ $i -gt 0 ] ;
	then
		previousMajorVersion=${branchesArray[$(($i-1))]}
	fi
done

if [ ! -d $localRepositoryPath/$localRepositoryDir ] ;
then
	echo 'cloning repository'
	cd $localRepositoryPath;
	mkdir $localRepositoryDir;
	git clone --branch $Branch $remoteRepositoryUrl $localRepositoryDir 1>&2>/dev/null
	cd $scriptDir;
else
	echo 'updating repository'
	cd $localRepositoryPath/$localRepositoryDir;
	git pull 1>&2>/dev/null
	cd $scriptDir;
fi

echo 'beginning building'
if [ -h $Original ] ;
then unlink $Original;
fi
ln -s $localRepositoryPath/$localRepositoryDir $Original

mkdir -p $buildsDir
rm -rf $Build

echo 'copying files'
cp -r $Original/ $Build

## Build version zip
if [ $sflag == 1 ] ;
then
	echo $sval > $Build/kernel/.build
else
	cd $localRepositoryPath/$localRepositoryDir;
	build_version=$(git describe --tags | cut -d '-' -f 2 | cut -d '.' -f 3)
	cd $scriptDir;
	if [ "$(echo $build_version | grep "^[ [:digit:] ]*$")" ] 
	then 
		echo $build_version > $Build/kernel/.build
	fi
	
	mkdir -p $exportDir/diff

	if [ $build_version -gt 0 ] ;
	then
		./make-diff.sh phpboost-$Branch.$(($build_version - 1)) phpboost-$Branch.$build_version $Branch;
		cp export/diff/* $exportDir/diff/
		rm -rf export/diff/
	fi
fi

## Nettoyage des dossiers
rm -rf $Build'/.gitignore' $Build'/.git' $Build'/.settings' $Build'/.project' $Build'/.htaccess' $Build'/test' $Build'/HomePage' $Build'/PHPBoostOfficial' $Build'/repository' $Build'/server_migration.php' $Build'/todo.txt' $Build'/changelog.txt' $Build'/templates/phpboost' $Build'/README.md'

## Suppression des fichiers .empty
find $Build -name '.empty' -exec rm -f '{}' \;

## Htaccess
touch $Build/.htaccess

## CHMOD
chmod -R 777 $Build'/cache' $Build'/upload' $Build'/templates' $Build'/lang' $Build'/images' $Build'/stats/cache' $Build'/install' $Build'/update'
chmod 777 $Build'/'
if [ $Branch == '3.0' ] || [ $Branch == '4.0' ] || [ $Branch == '4.1' ] ;
then chmod -R 777 $Build'/menus'
fi

################################ PDK pack ######################################

if [ $sflag != 1 ] ;
then
	echo 'building PDK pack'
	rm -rf $Build_pdk
	cp -r $Build/ $Build_pdk
	rm -rf $Build_pdk'/articles' $Build_pdk'/calendar' $Build_pdk'/contact' $Build_pdk'/download' $Build_pdk'/faq' $Build_pdk'/forum' $Build_pdk'/gallery' $Build_pdk'/online' $Build_pdk'/shoutbox' $Build_pdk'/guestbook' $Build_pdk'/ThemesSwitcher' $Build_pdk'/LangsSwitcher' $Build_pdk'/media' $Build_pdk'/news' $Build_pdk'/newsletter' $Build_pdk'/pages' $Build_pdk'/customization' $Build_pdk'/sitemap' $Build_pdk'/search' $Build_pdk'/poll' $Build_pdk'/stats' $Build_pdk'/update' $Build_pdk'/UrlUpdater' $Build_pdk'/web' $Build_pdk'/wiki'

	rm -rf $Build_pdk'/install/distribution.ini'
	rm -rf $Build_pdk'/install/lang/french/distribution.php'
	rm -rf $Build_pdk'/install/lang/english/distribution.php'
	mv $Build_pdk'/install/distribution/distribution_pdk.ini' $Build_pdk'/install/distribution.ini'
	mv $Build_pdk'/install/distribution/distribution_pdk_french.php' $Build_pdk'/install/lang/french/distribution.php'
	mv $Build_pdk'/install/distribution/distribution_pdk_english.php' $Build_pdk'/install/lang/english/distribution.php'
	rm -rf $Build_pdk'/install/distribution/'
fi

## Minify js files
echo 'minifying js files'
if [ -f phpboost/pages/templates/js/pages.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/pages/templates/js/pages.js' https://javascript-minifier.com/raw > $Build/pages/templates/js/pages.js ; fi
if [ -f phpboost/wiki/templates/js/wiki.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/wiki/templates/js/wiki.js' https://javascript-minifier.com/raw > $Build/wiki/templates/js/wiki.js ; fi
if [ -f phpboost/BBCode/templates/js/bbcode.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/BBCode/templates/js/bbcode.js' https://javascript-minifier.com/raw > $Build/BBCode/templates/js/bbcode.js ; fi
if [ -f phpboost/kernel/lib/js/global.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/global.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/global.js ; fi
if [ -f phpboost/kernel/lib/js/jquery/jquery.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/jquery/jquery.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/jquery/jquery.js ; fi
if [ -f phpboost/kernel/lib/js/lightcase/lightcase.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/lightcase/lightcase.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/lightcase/lightcase.js ; fi
if [ -f phpboost/kernel/lib/js/phpboost/notation.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/phpboost/notation.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/phpboost/notation.js ; fi
if [ -f phpboost/kernel/lib/js/phpboost/form/validator.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/phpboost/form/validator.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/phpboost/form/validator.js ; fi
if [ -f phpboost/kernel/lib/js/phpboost/form/form.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/phpboost/form/form.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/phpboost/form/form.js ; fi
if [ -f phpboost/kernel/lib/js/phpboost/UrlSerializedParameterEncoder.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/phpboost/UrlSerializedParameterEncoder.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/phpboost/UrlSerializedParameterEncoder.js ; fi
if [ -f phpboost/kernel/lib/js/phpboost/upload.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/js/phpboost/upload.js' https://javascript-minifier.com/raw > $Build/kernel/lib/js/phpboost/upload.js ; fi
if [ -f phpboost/kernel/lib/flash/flowplayer/flowplayer.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/kernel/lib/flash/flowplayer/flowplayer.js' https://javascript-minifier.com/raw > $Build/kernel/lib/flash/flowplayer/flowplayer.js ; fi
if [ -f phpboost/GoogleMaps/templates/js/jquery.geocomplete.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/GoogleMaps/templates/js/jquery.geocomplete.js' https://javascript-minifier.com/raw > $Build/GoogleMaps/templates/js/jquery.geocomplete.js ; fi
if [ -f phpboost/user/templates/js/cookiebar.js ]; then curl -X POST -s --data-urlencode 'input@phpboost/user/templates/js/cookiebar.js' https://javascript-minifier.com/raw > $Build/user/templates/js/cookiebar.js ; fi

## Optimize kernel
echo 'optimizing kernel'
java -jar bin/poptimizer.jar -i $Build/kernel -o $Build/optimized-kernel -e lib/ lib/php/geshi/ lib/php/mathpublisher/ framework/util/Url.class.php framework/io/Upload.class.php -ics ISO-8859-1 -ocs ISO-8859-1 1>/dev/null
rm -rf $Build'/kernel'
mv $Build'/optimized-kernel' $Build'/kernel'

################################ Full pack ######################################

echo 'building Full pack'
rm -rf $Build_full
cp -r $Build/ $Build_full
rm -rf $Build_full'/bugtracker'
rm -rf $Build_full'/doc'
rm -rf $Build_full'/sandbox'
rm -rf $Build_full'/update'
rm -rf $Build_full'/UrlUpdater'

rm -rf $Build_full'/install/distribution.ini'
rm -rf $Build_full'/install/lang/french/distribution.php'
rm -rf $Build_full'/install/lang/english/distribution.php'
mv $Build_full'/install/distribution/distribution_full.ini' $Build_full'/install/distribution.ini'
mv $Build_full'/install/distribution/distribution_full_french.php' $Build_full'/install/lang/french/distribution.php'
mv $Build_full'/install/distribution/distribution_full_english.php' $Build_full'/install/lang/english/distribution.php'
rm -rf $Build_full'/install/distribution/'

################################ Update pack ######################################

echo 'building Update pack'
rm -rf $Build_update
cp -r $Build/ $Build_update
rm -rf $Build_update'/bugtracker'
rm -rf $Build_update'/doc'
rm -rf $Build_update'/install'
rm -rf $Build_update'/sandbox'
rm -rf $Build_update'/.htaccess'

## Documentation
#mkdir -p $Build_pdk'/doc/'$Branch
#cp -R /tmp/phpboost/doc/* $Export_pdk'/doc/4.0'

################################

## Export modules zip
if [ $sflag != 1 ] ;
then
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
fi

################################

## On se place dans le répertoire
cd $scriptDir

## Export to zip
mkdir -p $exportDir/phpboost
mkdir -p $exportDir/update
cd $buildsDir/

if [ $sflag != 1 ] ;
then
	rm -rf $scriptDir/$exportDir/phpboost/phpboost.zip
	zip -r $scriptDir/$exportDir/phpboost/phpboost.zip phpboost/ 1>/dev/null
	rm -rf $scriptDir/$exportDir/phpboost/phpboost_pdk.zip
	zip -r $scriptDir/$exportDir/phpboost/phpboost_pdk.zip phpboost_pdk/ 1>/dev/null
else
	rm -rf $scriptDir/$exportDir/phpboost/phpboost_$sval.zip
	zip -r $scriptDir/$exportDir/phpboost/phpboost_$sval.zip phpboost/ 1>/dev/null
fi

UpdateZipName='update_phpboost'$(echo $previousMajorVersion | sed 's/\./_/g')'_to_'$(echo $Branch | sed 's/\./_/g')'.zip'
rm -rf $scriptDir/$exportDir/update/$UpdateZipName
zip -r $scriptDir/$exportDir/update/$UpdateZipName phpboost_update/ 1>/dev/null

cd $scriptDir
rm -rf $Build
unlink $Original
rm -rf 0

echo -e ''
if [ $sflag != 1 ] ;
then echo 'zip files are created for PHPBoost '$Branch'.'$build_version;
else echo 'zip files are created for the new PHPBoost special release '$sval;
fi

exit 0
