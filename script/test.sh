#!/bin/bash 

shopt -s expand_aliases
############!/usr/bin/env bash

#idifFileName="testuser"
#cat > ./${idifFileName}.idif <<HERE
#dn: cn=test user\${i},ou=people,dc=example,dc=com
#cn: test user\${i}
#objectClass: inetOrgPerson
#sn: user\${i}
#displayName: testuser\${i}
#mail: testuser\${i}@example.com
#userPassword: passw0rd
#HERE
#
#
#sed -i 's/${i}/2/g' ./testuser.idif


# for p in 

aaa=" a Pi "
bbb=" api "

echo "1 ${aaa:-} 2"
echo "3 ${aaa,,} 4"
echo "3 ${aaa^^} 4"

if [ "${bbb:-}" = "api-gateway" ] || [ "${bbb:-}" = "api" ]; then
  echo "if"
fi

if [ "${bbb:-}" = "api-gateway" ] || [ "${bbb:-}" = "null" ]; then
  echo "if"
fi


    set -x
function testArray {
  local -r barg1=${1}
  local -r barg2=${2}
  local -r barg3=${3}

  echo "arg1: ${barg1}"
  echo "arg2: ${barg2}"
  echo "arg3: ${barg3}"
#  IFS=$'\v'; read -ra newPaths <<< "${barg2}"
  newPaths=($barg2)
  declare -p newPaths
  arr_length=${#newPaths[@]}
  echo "arr_length: ${arr_length}"

  for item in "${newPaths[@]}"; do
    echo "path to move: ${item}"
  done;
}


    pathsToMove=(
     src
     package.json
     package-lock.json
     config
    );
##  for item in "${pathsToMove[@]}"; do
##    echo "path to move: ${item}"
##  done;

testArray "aarg1" "$( IFS=$'\n'; echo "${pathsToMove[*]}" )"

    set +x


# convert seconds to readable strign
function second2Readable {
  local -r T=$1
  local -r D=$((T/60/60/24))
  local -r H=$((T/60/60%24))
  local -r M=$((T/60%60))
  local -r S=$((T%60))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  printf '%d seconds\n' $S
}

echo "===seconds"
second2Readable 11617
## output: 42 seconds

second2Readable 42
## output: 42 seconds


# convert milliseconds to readable strign
function ms2Readable {
  local -r T=$1
  local -r D=$((T/1000/60/60/24))
  local -r H=$((T/1000/60/60%24))
  local -r M=$((T/1000/60%60))
  local -r S=$((T/1000%60))
  local -r MS=$((T%1000))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
#  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  (( $S > 0 )) && printf '%d seconds ' $S
  printf '%d milliseconds\n' $MS
}

echo "===milliseconds"

ms2Readable 42
ms2Readable 1211617

# convert nano to readable strign
function nano2Readable {
  local -r ori=$1
  # convert nano to milliseconds
  local -r T=$((ori/1000000))
  local -r D=$((T/1000/60/60/24))
  local -r H=$((T/1000/60/60%24))
  local -r M=$((T/1000/60%60))
  local -r S=$((T/1000%60))
  local -r MS=$((T%1000))
  (( $D > 0 )) && printf '%d days ' $D
  (( $H > 0 )) && printf '%d hours ' $H
  (( $M > 0 )) && printf '%d minutes ' $M
#  (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
  (( $S > 0 )) && printf '%d seconds ' $S
  printf '%d milliseconds\n' $MS
}

echo "===nano"


nano2Readable 34829817117
nano2Readable 1211617

# refer:
# https://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds


totalTimeCost=34829817117
echo Execution time was `nano2Readable ${totalTimeCost}`.


function testReturnVal {
  echo "line1" 
  echo "line2" 
  exit 0
}


returnVal=$(testReturnVal)
ret=$?
echo "returnVal: ${returnVal}, ret: ${ret}"

# ls -AlpkFih ./
# IFS=$'\n'; read -ra ADDR <<< `cat ./pvtTime.txt`
array=(`cat ./pvtTime.txt`)
declare -p array
startArray=()
endArray=()

for item in ${array[@]}; do
  tmpArray=(`echo $item | tr ',' ' '`)
  startArray+=(${tmpArray[0]})
  endArray+=(${tmpArray[1]})
done


declare -p startArray
declare -p endArray

echo "====try to sort"
startArray_sorted=( $( printf "%s\n" "${startArray[@]}" | sort -n ) )
endArray_sorted=( $( printf "%s\n" "${endArray[@]}" | sort -n ) )

declare -p startArray_sorted
declare -p endArray_sorted

# start_new=
# end_new=${startArray_sorted[0]}
# totalTimeCost2=((end_new-start_new))
totalTimeCost2=`expr ${endArray_sorted[${#endArray_sorted[@]} - 1]} - ${startArray_sorted[0]}`
echo Execution time was `nano2Readable ${totalTimeCost2}`.

for file in a b ; do
  echo "file: ${file}"
done

# AAAAA=44444444444444444444444 env

CONTAINER_INDEX=${CONTAINER_INDEX:-0}
echo "CONTAINER_INDEX: ${CONTAINER_INDEX}"
