#!/bin/bash

tmpPath='/tmp/phpboost' && mkdir ${tmpPath} 2> /dev/null
tmpDocPath=${tmpPath}'/doc' && rm -rf ${tmpDocPath} && mkdir ${tmpDocPath}

cd ${1} && directory=`pwd`
cd ${2} && source=`pwd` && cd ${directory}

##### Injecting package names #####

source `dirname $0`/inject_packages.sh
inject_packages $source/kernel/framework

##### Generating documentation #####
path=`dirname $0`
phpdoc=${path}/../phpdoc && cd ${phpdoc} && phpdoc=${directory}/phpdoc > /dev/null 2>&1

## Title of generated documentation, default is 'Generated Documentation'
TITLE="PHPBoost Framework Documentation"
## Default package name
PACKAGES="phpboost"
## Directories to parse : directory1,directory2
PATH_PROJECT=$source/kernel/framework/*.class.php,$source/kernel/framework/*.inc.php
IGNORE_PATH=lib/,js/,ajax/,content/geshi/,content/math/,content/tinymce/,*/sha256.class.php,*/index.php

## PHPDoc executable
## Output target
PATH_DOCS=${tmpDocPath}

CUSTOM_TAGS=warning ## Custom tags
PRIVATE=off ## Parse private
PEAR=on ## Pear Mode

## Output format to use (html/pdf)
OUTPUTFORMAT=HTML
CONVERTER=Smarty
TEMPLATE=phpboost

# make documentation
${phpdoc} -f "$PATH_PROJECT" -t "$PATH_DOCS" -ti "$TITLE" -dn "$PACKAGES" -ct "$CUSTOM_TAGS" -o "$OUTPUTFORMAT:$CONVERTER:$TEMPLATE" -p "$PEAR" -pp "$PRIVATE" -i "$IGNORE_PATH" -j on

function html2php()
{
	filesToConvert=`find $1 -name "*.html"`
	for file in $filesToConvert
	do
		htmlName=`echo $file | sed -e 's/^\(.*\)\.html$/\1\.php/g'`
		mv $file $htmlName
		sed -i -r 's/"([^"]+)\.html(#[^"]+)?"/"\1\.php\2\"/g' $htmlName
	done
}

##### Converting documentation from HTML to PHP #####
html2php $PATH_DOCS
