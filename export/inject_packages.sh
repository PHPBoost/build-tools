#!/bin/sh

# $1 is the path of the root of the directory tree in which packages have to be injected. All subdirectories will be packages
function inject_packages()
{
	for file in `ls $1`
	do
		path=$1/$file
		if [ -d $path ]
		then
			inject_package $path $file
		fi
	done
}

# $1 is the path of the package
# $2 is the name of the package
function inject_package()
{
	for file in `ls $1`
	do
		path=$1/$file
		if [ -f $path ]
		then
			replace_package $path $2
		elif [ -d $path ]
		then
			inject_subpackage $path $2 $file 
		fi
	done
}

# $1 is the path of the file in which the replacement must be done
# $2 is the value of the {@package} variable
function replace_package()
{
	pattern="s/{@package}/"$2"/"
	sed -i $pattern $1 
}


# $1 is the path of the file in which the replacement must be done
# $2 is the value of the {@package} variable
# $3 is the value of the {@subpackage} variable
function inject_subpackage()
{
	for file in `ls $1`
        do
		path=$1/$file
                if [ -f $path ]
                then
                        replace_subpackage $path $2 $3
                elif [ -d $path ]
                then
			subpackage=$3/$file
			inject_subpackage $path $2 $subpackage
                fi
        done

}

# $1 is the path of the file in which the replacement must be done
# $2 is the value of the @package variable
# $3 is the value of the @subpackage variable
function replace_subpackage()
{
	sed -i 's#{@package}#'$2'\n * @subpackage '$3'#' $1
}

