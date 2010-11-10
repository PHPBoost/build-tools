here=`pwd`

branchDir=`dirname $0`
cd $branchDir 
branchDir=`pwd`
cd $here

${branchDir}/build.sh ${branchDir}/../../../../branches/3.0 $1

