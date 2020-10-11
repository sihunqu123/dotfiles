#!/bin/bash

echo "in sb launcher"

set -o errexit
set -o pipefail
#set -o nounset
######################################################################################
### If you failed to run this script, pls enable below 2 lines to enable debugging ###
######################################################################################
# set -v
# set -o xtrace

shopt -s expand_aliases

#
# Judge if a command is available
# @param 1: the command to judge
#
function hasCommand {
  # the `set -o errexit` set in upper scope won't affect env in this function's scope
  # thus script won't terminate even when ${1} doesn't not exits.
  which ${1}
  local -r ret=$?
  if ((exitStatus==0)); then
    echo "true"
  else
    echo "false"
  fi
}

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

function getPathNameInfo {
  thePath=$(echo ${theStr} | grep -oP ".*\/(?=[^/]+)") && echo "path: ${thePath}"
  theFile=${theStr#${thePath}} && echo "filename: ${theFile}"
  theNameOnly=${theFile%.*} && echo "nameOnly(without Extension): ${theNameOnly}"
  theDotExtension=${theFile#${theNameOnly}} && echo "dotExtension: ${theDotExtension}"
}

declare -r uname=$(uname)
declare currentOS=""
# to make `grep`  compatible with all platforms

case "$uname" in
    (*Linux*) currentOS='Linux';
              echo "OS is Linux"
              alias _grep="grep"
              ;;
    (*Darwin*) currentOS='Darwin';
              echo "OS is MacOS."
              has_ggrep=$(hasCommand ggrep)
              if [ "${has_ggrep}" = "true" ]; then # aria2c is available
                echo "[check] GNU utils is install, ready to run"
                alias _grep="ggrep"
              else
                echo "Error: pls make sure ggrep(the GNU grep) is install. Tips: run
                brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt
                For details, pls refer to:
                  https://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities"
                exit 2;
              fi
              ;;
    (*CYGWIN*) currentOS='CYGWIN';
              echo "OS is CYGWIN"
              alias _grep="grep"
              ;;
    (*) echo 'error: unsupported platform.'; exit 2; ;;
esac;

_grep --version

echo "currentOS is :${currentOS}"


# Set magic variables for current file & dir
declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
declare -r __base="$(basename ${__file} .sh)"
declare -r __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

declare -r githubPath="/opt/github/Atlas/sourcecode"
declare -r tmpPath="${githubPath}/tmp"
declare -r host_githubPath="/media/sf_github"  # change to a path with enough ACL if u r are Mac user.
declare -r host_side_githubPath="/d/github" # change to a path with enough ACL if u r are Mac user.
declare -r nodeCommonUtilsPath="${githubPath}/node-common-utils"
declare -r nodeCommonUtilsLibPath="node_modules/@atlas/node-common-utils"
# the namespace for kubectl cluster
# declare -r namespace_default=default
namespace_default=${CONTAINER_NAMESPACE:-default}
CONTAINER_INDEX=${CONTAINER_INDEX:-0}

declare -r minioUser=minioadmin
declare -r minioPwd="miniopassword"

declare -r arg1="${1:-}"
declare -r arg2="${2:-}"
echo arg1: ${arg1} arg2: ${arg2} __dir: ${__dir} __file: ${__file} __base: ${__base} __root: ${__root}


## if [ "${1:-}" = "" ] || [ "${2:-}" = "" ]; then
if [ "${1:-}" = "" ]; then
  echo "usage: ${__file} project_name [method]"
  exit 107
fi

declare -r _project=$1
#  url=${URL_base}${2}" "${3:-}" "${4:-}" "${5:-}" "${6:-}" "${7:-}" "${8:-}" "${9:-}

#  echo url: ${url}
shift 1
declare -r _method=$1
shift 1
declare -r _param=$1

#set -x
#${__dir}/testRunner.sh "$@"
#ret=$?
#set +x
#  echo "res: ${response_text}"


#
# reload Atlas-UI to the docker container
# @param 1: the method to do
#
function reloadAtlasUI {
  local -r project_name="atlas-ui"
  local -r linux_project_path="${githubPath}/${project_name}"
  local -r container_project_path=/usr/local/site/${project_name}
  local -r containerName="atlas-uiui-${CONTAINER_INDEX}"

  if [ -e ${linux_project_path}/dist/ ]; then
    echo "${linux_project_path}/dist/ exists"
  else
    echo "Error: ${linux_project_path}/dist/ doesn't exists!!! Pls make sure generating build result in this folder."
    exit 2
  fi
  ls  -A1t  ${linux_project_path}/dist/*.hot-update.* |tail -n +4 | xargs -I % -L 1 rm -rfv %
  # docker exec -it ${containerName} sh -c 'rm -rfv ${container_project_path}/*.hot-update.*'
  kubectl exec -it -n ${namespace_default} ${containerName} -- sh -c 'rm -rfv ${container_project_path}/*.hot-update.*'
  cp -fRpv ${linux_project_path}/{public/locales,dist/}
  # find ${linux_project_path}/dist/ -maxdepth 1 -mindepth 1 -print |_grep -v "\.swp" |xargs -L 1 -I % docker cp % ${containerName}:${container_project_path}/
  find ${linux_project_path}/dist/ -maxdepth 1 -mindepth 1 -print |_grep -v "\.swp" |xargs -L 1 -I % kubectl cp % ${namespace_default}/${containerName}:${container_project_path}/
}

#
# reload files-svc, also copy linux src to host(overwrite), and then to the docker container
# @param 1: the method to do
# @param 2: whether need to launch with --inspect-brk. default --inspect
#
function filesSVC {
  local -r project_key="files"
  local -r project_name="${project_key}-microservice"
  local -r linux_project_path="${githubPath}/${project_name}"
  local -r host_project_path="${host_githubPath}/${project_name}"
  local -r host_side_project_path="${host_side_githubPath}/${project_name}"
  local -r container_project_path=/usr/local/site/${project_name}
  local -r containerName="atlas-${project_key}-0"

  local -r method=${1}
  local -r isBrk=${2}

  if [ "${method:-}" = "tar" ]; then # to tar node_modules/ files from container
    kubectl exec -it ${containerName} -- sh -c "
      cd ${container_project_path} &&
      tar cf n.tar node_modules/
    "
    docker cp ${containerName}:${container_project_path}/n.tar ${linux_project_path}/
    tar xf n.tar
    cp -fRpv n.tar ${host_project_path}/
    echo -e -n "please run:\n tar xf ${host_side_project_path}/n.tar -C ${host_side_project_path}/\nin host's bash terminal.\n"
  elif [ "${method:-}" = "push" ]; then # push local node_moudles to conainer
    (\
      cd ${linux_project_path} && \
      tar cf n2.tar node_modules/ \
    )
    kubectl cp ${linux_project_path}/n2.tar ${namespace_default}/${containerName}:${container_project_path}/
    kubectl exec -n ${namespace_default}  -it ${containerName} -- sh -c "
      cd ${container_project_path} &&
      tar xf n2.tar
    "
    cp -fRpv ${linux_project_path}/n2.tar ${host_project_path}/
    echo -e -n "please run:\n tar xf ${host_side_project_path}/n2.tar -C ${host_side_project_path}/\nin host's bash terminal.\n"
  else # to sync and restart
    local -r inspectVal="inspect"

    if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
      inspectVal="inspect-brk"
    fi

    echo "about to reload debug "
    set +x

    local -r pathsToMove=(
     src
     package.json
     package-lock.json
     config
    );
    for item in "${pathsToMove[@]}"; do
      cp -fRpv "${linux_project_path}/${item}" "${host_project_path}/"
      kubectl cp "${linux_project_path}/${item}" ${namespace_default}/${containerName}:"${container_project_path}/"
    done;

##  find ${linux_project_path} -mindepth 1 -maxdepth 1 | _grep -Ev "/(src|.json|config|.git|node_modules)$" |xargs -L 1 -I % sh -c "
##    cp -fRpv % ${host_project_path} &&
##    kubectl cp % ${namespace_default}/${containerName}:${container_project_path}/
##  "
    echo "=================================="
    find ${nodeCommonUtilsPath}/ -mindepth 1 -maxdepth 1 | _grep -P "(\/lib|src|.json)$"
    echo "=================================="

    find ${nodeCommonUtilsPath}/ -mindepth 1 -maxdepth 1 | _grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % sh -c "
      mkdir -p ${linux_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${linux_project_path}/${nodeCommonUtilsLibPath}/ &&
      mkdir -p ${host_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${host_project_path}/${nodeCommonUtilsLibPath}/ &&
      kubectl cp % ${namespace_default}/${containerName}:${container_project_path}/${nodeCommonUtilsLibPath}/
    "

    # start project in container
    kubectl exec -it ${containerName} -- bash -c "source /etc/profile
      cd ${container_project_path}/ && \
      export NODE_ENV=production && \
      svc -d /service/${project_name}/ && \
      node --inspect=0.0.0.0:9229 .
    "
  fi
}

#
# reload api-gatway, also copy linux src to host(overwrite), and then to the docker container
# @param 1: the method to do
# @param 2: whether need to launch with --inspect-brk. default --inspect
#
function reloadAPI_gateway {
  local -r linux_project_path="${githubPath}/api-gateway"
  local -r host_project_path="${host_githubPath}/api-gateway"
  local -r container_project_path="/usr/local/site/api-gateway"
  local -r containerName="atlas-doad-0"

  local -r isBrk=${2}
  local inspectVal="inspect"

  if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
    inspectVal="inspect-brk"
  fi

  echo "about to reload debug "
  docker exec -it ${containerName} svc -d /service/api-gateway
  cp -fRpv ${linux_project_path}/common ${linux_project_path}/server ${linux_project_path}/package.json ${linux_project_path}/package-lock.json ${linux_project_path}/config  ${host_project_path}/
  docker cp ${linux_project_path}/common ${containerName}:${container_project_path}/
  docker cp ${linux_project_path}/server ${containerName}:${container_project_path}/
  docker cp ${linux_project_path}/config ${containerName}:${container_project_path}/
  docker cp ${linux_project_path}/package.json ${containerName}:${container_project_path}/
  docker cp ${linux_project_path}/package-lock.json ${containerName}:${container_project_path}/
  find ${nodeCommonUtilsPath}/ -mindepth 1 -maxdepth 1 |_grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % sh -c "
    mkdir -p ${linux_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${linux_project_path}/${nodeCommonUtilsLibPath}/ &&
    mkdir -p ${host_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${host_project_path}/${nodeCommonUtilsLibPath}/ &&
    docker cp % ${containerName}:${container_project_path}/${nodeCommonUtilsLibPath}/
  "
  docker exec -it ${containerName} bash -c "source /etc/profile
    cd ${container_project_path}/ && \
    export NODE_ENV=production && \
    svc -d /service/api-gateway/ && \
    node --${inspectVal}=0.0.0.0:9229 .
  "
}

#
# Copy files in given folder of given container to given path in the host
# @param 1: containerName - the name of the container
# @param 2: fromPath - the absolute source path in the container
# @param 3: toPath - the relative/absolute target path in the host
# @example copyFolderFromContainer2Host atlas-ldapsync-0 /abc/d ./asdb default
#
function copyFolderFromContainer2Host {
  local -r containerName=${1}
  local -r fromPath=${2}
  local -r toPath=${3}
  echo "copyFolderFromContainer2Host - containerName: ${containerName}, fromPath: ${fromPath}, toPath: ${toPath}"
  mkdir -p "${toPath}"
  kubectl exec -n ${namespace_default} ${containerName} -- sh -c "cd ${fromPath} && tar cf - ./" | tar xf - -C "${toPath}/"
  # kubectl exec atlas-ldapsync-0 -- sh -c "cd /usr/local/site/ldapsync-microservice/config/ && tar cf - ./" | tar xf - -C ./config/
}

#
# reload ldapsync, also copy linux src to host(overwrite), and then to the docker container
# @param 1: the method to do
# @param 2: whether need to launch with --inspect-brk. default --inspect
#
function reloadLdapsync {
  # copyFolderFromContainer2Host atlas-ldapsync-0 /abc/d ./asdb
  # exit 0
  local -r project_key="ldapsync"
  local -r project_name="${project_key}-microservice"
  local -r linux_project_path="${githubPath}/${project_name}"
  local -r host_project_path="${host_githubPath}/${project_name}"
  local -r container_project_path="/usr/local/site/${project_name}"
  local -r containerName="atlas-${project_key}-0"

  local -r isBrk=${2}
  local inspectVal="inspect"

  if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
    inspectVal="inspect-brk"
  fi

  echo "about to reload debug "
  # first stop project in container to avoid "failed to delete"
  kubectl exec -it ${containerName} -- svc -d /service/${project_name}

#   cp -fRpv ${host_project_path}/
# array=( \
#  ${linux_project_path}/src \
#  ${linux_project_path}/test \
#  ${linux_project_path}/package.json \
#  ${linux_project_path}/package-lock.json \
#  ${linux_project_path}/config  \
# ); for item in "${array[@]}"; do cp -fRpv /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/cdma/service/startup-action/common.yml \
# /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/${item}/service/startup-action/ && \
# cp -fRpv /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/cdma/service/template/usr/local/site/config/fluent-bit/conf.d/common.conf \
# /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/${item}/service/template/usr/local/site/config/fluent-bit/conf.d/ ; done;

  local -r pathsToMove=(
   src
   test
   package.json
   package-lock.json
   config
  );
  for item in "${pathsToMove[@]}"; do
    echo "cp ${linux_project_path}/${item} to ${host_project_path}/"
    echo "kubectl cp ${linux_project_path}/${item} ${namespace_default}/${containerName}:${container_project_path}/"
  done;

  # sync node-common-utils
  find ${nodeCommonUtilsPath}/ -mindepth 1 -maxdepth 1 |_grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % sh -c "
    mkdir -p ${linux_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${linux_project_path}/${nodeCommonUtilsLibPath}/ &&
    mkdir -p ${host_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${host_project_path}/${nodeCommonUtilsLibPath}/ &&
    kubectl cp % ${namespace_default}/${containerName}:${container_project_path}/${nodeCommonUtilsLibPath}/
  "
  # start project in container
  kubectl exec -it ${containerName} -- bash -c "source /etc/profile
    cd ${container_project_path}/ && \
    export NODE_ENV=production && \
    svc -d /service/${project_name}/ && \
    node --${inspectVal}=0.0.0.0:9229 .
  "
}

#
# reload a project in a contianer, also copy linux src to host(overwrite), and then to the docker container
# @param 1: the method to do
# @param 2: whether need to launch with --inspect-brk. default --inspect
# @param 3: project_key
# @param 4: whether need to sync node-common-utils; default: false
# @param 5: paths to sync
# @param 6: whether need to add 'microservice' as project_name. default: true
#
function reloadMicroSVC {
  # copyFolderFromContainer2Host atlas-ldapsync-0 /abc/d ./asdb default
  # exit 0
  set -o errexit
  local -r isSyncNodeCommonUtils="${4:-false}"
  local -r isAppendMicroSVC="${6:-true}"

  local -r project_key="${3}"
  local project_name="${project_key}"
  if [ "${isAppendMicroSVC:-}" = "true" ] || [ "${isAppendMicroSVC:-}" = "1" ]; then
    project_name="${project_key}-microservice"
  fi
  local -r linux_project_path="${githubPath}/${project_name}"
  local -r host_project_path="${host_githubPath}/${project_name}"
  local -r container_project_path="/usr/local/site/${project_name}"
  local -r containerName="atlas-${project_key}-${CONTAINER_INDEX}"

  local -r method=${1}
  local -r isBrk=${2}
  local -r pathsToMove=($5)

  if [ "${method:-}" = "tar" ]; then # to tar node_modules/ files from container
    docker exec -it ${containerName} sh -c "
      cd ${container_project_path} &&
      tar cf n.tar node_modules/
    "
    docker cp ${containerName}:${container_project_path}/n.tar ${linux_project_path}/
    tar xf n.tar
    cp -fRpv n.tar ${host_project_path}/
    echo -e -n "please run:\n tar xf ${host_side_project_path}/n.tar -C ${host_side_project_path}/\nin host's bash terminal.\n"
  elif [ "${method:-}" = "config" ]; then # copy the config from conainer to local
    copyFolderFromContainer2Host ${containerName} ${container_project_path}/config/ ${linux_project_path}/config
    mkdir -p ${host_project_path}/
    cp -fRpv ${linux_project_path}/config  ${host_project_path}/
  elif [ "${method:-}" = "push" ]; then # push local node_moudles to conainer
    set -x
    (\
      cd ${linux_project_path} && \
      tar cf n2.tar node_modules/ \
    )
    set +x
    kubectl cp ${linux_project_path}/n2.tar ${namespace_default}/${containerName}:${container_project_path}/
    kubectl exec -it -n ${namespace_default} ${containerName} -- sh -c "
      cd ${container_project_path} &&
      tar xf n2.tar
    "
    mkdir -p ${host_project_path}/
    cp -fRpv ${linux_project_path}/n2.tar ${host_project_path}/
    echo -e -n "please run:\n tar xf ${host_side_project_path}/n2.tar -C ${host_side_project_path}/\nin host's bash terminal.\n"
  else # to sync and restart
    local inspectVal="inspect"
    if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
      inspectVal="inspect-brk"
    fi

    echo "about to reload debug "

    # first stop project in container to avoid "failed to delete"
    kubectl exec -it -n ${namespace_default} ${containerName} -- svc -d /service/${project_name}
  
    for item in "${pathsToMove[@]}"; do
      cp -fRpv "${linux_project_path}/${item}" "${host_project_path}/"
      kubectl cp "${linux_project_path}/${item}" ${namespace_default}/${containerName}:"${container_project_path}/"
    done;
  
    # sync node-common-utils
    if [ "${isSyncNodeCommonUtils:-}" = "true" ] || [ "${isSyncNodeCommonUtils:-}" = "1" ]; then
      find ${nodeCommonUtilsPath}/ -mindepth 1 -maxdepth 1 |_grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % sh -c "
        mkdir -p ${linux_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${linux_project_path}/${nodeCommonUtilsLibPath}/ &&
        mkdir -p ${host_project_path}/${nodeCommonUtilsLibPath}/ && cp -fRpv % ${host_project_path}/${nodeCommonUtilsLibPath}/ &&
        kubectl cp % ${namespace_default}/${containerName}:${container_project_path}/${nodeCommonUtilsLibPath}/
      "
    fi

    local -r libPaths=(
      "@atlas/js-logger"
      "bunyan"
    )

    for item in "${libPaths[@]}"; do
      libPath="node_modules/${item}"
      mkdir -p ${linux_project_path}/${libPath}/ && 
      mkdir -p ${host_project_path}/${libPath}/ && cp -fRpv ${linux_project_path}/${libPath}/* ${host_project_path}/${libPath}/
      parentPath=$(echo ${container_project_path}/${libPath} | grep -oP ".*\/(?=[^/]+)") 
      kubectl cp ${linux_project_path}/${libPath} ${namespace_default}/${containerName}:${parentPath}
    done;
    
    # start project in container
    ## use the deadloop echo to prevent disconnected by the loadbalancer
    kubectl exec -it -n ${namespace_default} ${containerName} -- bash -c "source /etc/profile
      cd ${container_project_path}/ && \
      export NODE_ENV=production && \
      svc -d /service/${project_name}/ && \
      node . &
      while :; do sleep 59; echo -n ' ' >&2; done &
      sleep 3
      tail -f /var/log/${project_name}/${project_name}.log
    "
  fi
}

#
# create a default bucket in minio container
#
# docker exec -it -u 0 atlas-operation /usr/local/src/scripts/operation/admin.js createFilesBuckets
function createBucket {
  local -r linux_mcPath=/opt/shared/mc
  local -r container_project_path=/opt/shared
  local -r containerName="atlas-minio-0"

  # first, check if the mc exits in ${linux_mcPath}
  if [ -e ${linux_mcPath} ]; then
    echo "${linux_mcPath} already exists"
  else
    echo "${linux_mcPath} does not exists, will download it now..."
    local -r filePath=$(echo ${linux_mcPath} | _grep -oP ".*\/(?=[^/]+)")
    local -r filename=${theStr#${thePath}}
    # pls make sure aria2c is install
    local -r has_aria2c=$(hasCommand aria2c)

    if [ "${has_aria2c}" = "true" ]; then # aria2c is available
      aria2c --check-certificate=false --dir=${filePath} --out=${filename} -x 8 -s 8 https://dl.min.io/client/mc/release/linux-amd64/mc
    else
      echo "if the download is too slow, pls install aria2c and then try again."
      # single-thread download is too slow.
      (\
        cd ${filePath} && \
        wget https://dl.min.io/client/mc/release/linux-amd64/mc
      )
    fi
  fi

  docker exec -it -u 0 ${containerName} mkdir -p ${container_project_path}/
  docker cp ${linux_mcPath} ${containerName}:${container_project_path}/
  docker exec -it ${containerName} bash -c "
    cd ${container_project_path}/ && \
    chmod -R 777 ./* && \
    ./mc config host add minio http://minio.service.ext.atlas.com:9000 ${minioUser} ${minioPwd} && \
    ./mc mb minio/local.atlas.com.cobrand && \
    ./mc ls minio
  "
  local -r ret=$?
  if (( exitStatus == 0 )); then
    echo "create bucket:local.atlas.com.cobrand successfully!"
  else
    echo "Error: create bucket failed! Pls make sure the minioKey and minioSecret are correct!"
  fi
}

# add default users
function addDefaultUser {
  local -r method=${1}
  local -r isBrk=${2}
  local inspectVal="inspect"

  if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
    inspectVal="inspect-brk"
  fi

  docker exec -it -u 0 atlas-operation sh -c "node --${inspectVal}=0.0.0.0:9241 /usr/local/src/scripts/operation/admin.js addDefaultUsers"
}

# change the session timeout to a longer time

# the unit of this SESSION_INACTIVE_TIMEOUT is:
#   expire
#   Expiration time of the item. If it's equal to zero, the item will never expire. You can also use Unix timestamp or a number of seconds starting from current time, but in the latter case the number of seconds may not exceed 2592000 (30 days).
# refer: https://stackoverflow.com/questions/6027517/can-the-time-to-live-ttl-for-a-memcached-key-be-set-to-infinite
function longerSession {
  # docker exec -it atlas-authen-0 sed -i 's/SESSION_INACTIVE_TIMEOUT =[^;]\+;/SESSION_INACTIVE_TIMEOUT = 999999;/g' /usr/local/site/authen-microservice/src/common/utils.js
# docker exec -it atlas-authen-0 sed -i 's/SESSION_INACTIVE_TIMEOUT =[^;]\+;/SESSION_INACTIVE_TIMEOUT = 0;/g' /usr/local/site/authen-microservice/src/common/utils.js
# docker exec -it atlas-authen-0 svc -du '/service/authen-microservice/'
  kubectl exec -it -n ${namespace_default} atlas-authen-0 -- sed -i 's/SESSION_INACTIVE_TIMEOUT =[^;]\+;/SESSION_INACTIVE_TIMEOUT = 0;/g' /usr/local/site/authen-microservice/src/common/utils.js
  kubectl exec -it -n ${namespace_default} atlas-authen-0 -- svc -du '/service/authen-microservice/'
}

# removeOperation, including container, images
function removeOperation {
  ## cancel pipefail, since below may failed when all are clean
  set +o pipefail
  # remove all atlas container
  echo "about to stop all atlas container.."
  docker ps -a |grep atlas |awk '{print $NF;}' |xargs -L 1 -I % docker container rm -f %
  echo "===========result -  docker ps -a"
  docker ps -a

  # remove all service
  echo "about to delete all atlas service..."
  docker service ls  |awk '{if(NR > 1) print $1;}' |xargs -L 1 -I % docker service rm %
  echo "===========result -  docker service ls"
  docker service ls

  # remove all config
  echo "about to delete all atlas config..."
  docker config ls |awk '{if(NR > 1) print $1;}' |xargs -L 1 -I % docker config rm %
  echo "===========result -  docker config ls"
  docker config ls

  echo "about to clean all atlas volume..."

  docker ps -a |grep atlas |awk '{ if(NR>-9) print $NF;}' |xargs -L 1 -I % docker rm --force %
  docker volume ls |grep atlas |awk '{print $NF;}' |xargs -L 1 -I % docker volume rm %
  echo "===========result -  docker volume ls"
  docker volume ls

  docker images |grep operation |awk '{print $3}' |uniq |xargs -L 1 -I % docker rmi --force %
}

# cleanAll, including container, svc, volume
function cleanAll {
  ## cancel pipefail, since below may failed when all are clean
  set +o pipefail
  # remove all atlas container
  echo "about to stop all atlas container.."
  docker ps -a |grep atlas |awk '{print $NF;}' |xargs -L 1 -I % docker container rm -f %
  echo "===========result -  docker ps -a"
  docker ps -a

  # remove all service
  echo "about to delete all atlas service..."
  docker service ls  |awk '{if(NR > 1) print $1;}' |xargs -L 1 -I % docker service rm %
  echo "===========result -  docker service ls"
  docker service ls

  # remove all config
  echo "about to delete all atlas config..."
  docker config ls |awk '{if(NR > 1) print $1;}' |xargs -L 1 -I % docker config rm %
  echo "===========result -  docker config ls"
  docker config ls

  echo "about to clean all atlas volume..."

  docker ps -a |grep atlas |awk '{ if(NR>-9) print $NF;}' |xargs -L 1 -I % docker rm --force %
  docker volume ls |grep atlas |awk '{print $NF;}' |xargs -L 1 -I % docker volume rm %
  echo "===========result -  docker volume ls"
  docker volume ls
}

#
# reload adminUI(citadel-config-panel), also copy linux src to linux host
# @param 1: the method to do
#
# # to sync AdminUI production
# find /opt/github/Atlas/sourcecode/citadel-control-panel/dist/admin -mindepth 0 -maxdepth 1  -type f  |egrep "*\.(map|js|html)$" |xargs -L 1 -I % docker cp % atlas-uiui-0:/usr/local/site/citadel-control-panel/admin/
function adminUI {
  local -r project_name="citadel-control-panel"
  local -r linux_project_path="${githubPath}/${project_name}"
  local -r tmp_linux_project_path_admin="${tmpPath}/${project_name}/admin"
  local -r container_project_path=/usr/local/site/${project_name}
  local -r containerName="atlas-uiui-0"

  local -r method=${1}

  if [ "${method:-}" = "tar" ]; then # to tar node_modules/ files from container
    docker exec -it ${containerName} sh -c "
      cd '/usr/local/site/' &&
      tar cf n.tar ${project_name}/
    "
    docker cp ${containerName}:/usr/local/site/n.tar ${tmpPath}/
    (\
      cd ${tmpPath} && \
      tar xf n.tar \
    )
    echo -e -n "Succeed in syncing remote files to local ${tmpPath}!"
  else # to sync and restart
    echo "about to reload debug "
    set -x

    # first cp the build result template from container to .tmp
    cp -fRpv ${tmp_linux_project_path_admin}/{app,index.html} ${linux_project_path}/.tmp/
    mkdir -p ${linux_project_path}/.tmp/assets
    # then continue to sync some resources from container to .tmp/assets
    cp -fRpv ${tmp_linux_project_path_admin}/assets/{fonts,libs} ${linux_project_path}/.tmp/assets/
    # then sync some resources from local src
    cp -fRpv ${linux_project_path}/src/app/i18n ${linux_project_path}/.tmp/app/
    cp -fRpv ${linux_project_path}/src/assets/{env.js,theme.js,theme.scss}  ${linux_project_path}/.tmp/assets/

    # generate some default cobrand configs
#   local.atlas.com.cobrand


#   for fileFullPath in ${linux_project_path}/.tmp/assets/{env.js,theme.scss,theme.js}; do
#     echo "filePullPath: ${fileFullPath}"
#
#   done

    cp -fRpv ${linux_project_path}/.tmp/assets/env.js ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.env.js
    cp -fRpv ${linux_project_path}/.tmp/assets/theme.scss ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.theme.css
    cp -fRpv ${linux_project_path}/.tmp/assets/theme.js ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.theme.js
    cp -fRpv ${linux_project_path}/.tmp/assets/env.js ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.env.js

    # remote old files
    docker exec -it atlas-uiui-0 rm -rfv ${container_project_path}/admin
    # copy local new files to remote
    docker cp ${linux_project_path}/.tmp/ ${containerName}:${container_project_path}/admin
  fi
}

function renameSpec {
  cd /opt/github/Atlas/sourcecode/citadel-control-panel
  local -r method=${1}
  local -r paths='src/app src/components'


  if [ "${method:-}" = "rename" ]; then # to rename to tiantcbak
    function renameOnePath {
      local -r doPath=${1}
      for item  in $(find ${doPath} -mindepth 0 -maxdepth 999 -name "*.spec.js"); do
        # echo "item: ${item}"
        case "$item" in

          (src/app/citadel/cobrand-admin/create-customer.controller.spec.js);&
          (src/app/citadel/cobrand-admin/create-customer.controller.spec.js1)  echo  "${item} will skip ---------"
            ;;
          (*)
            #       echo "${item}, won't skip"
            mv -v "${item}" "${item}.tiantcbak"
            ;;
        esac
      done
    }

    for p in ${paths}; do
      renameOnePath ${p}
    done

  else # to recover
    function recoverOnePath {
      local -r doPath=${1}
      for item  in $(find ${doPath} -mindepth 0 -maxdepth 999 -name "*.tiantcbak"); do
        # echo "item: ${item}"
        mv -v "${item}" "${item%.tiantcbak}"
        #echo "${item%.tiantcbak}"
      done
    }

    for p in ${paths}; do
      recoverOnePath ${p}
    done
  fi
}

function syncDockerRepo {
  local -r linux_project_path="${githubPath}/wispr-node-buildtools"

  (\
    cd ${linux_project_path}/sandbox/buildroot/git/master/docker && \
    git pull origin master --rebase
    git push -f -u mine master
  )

  (\
    cd ${linux_project_path}/sandbox/buildroot/git/master/base/docker && \
    git fetch mine
    git reset --hard mine/master
  )
}

function syncOperation {
  # find /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/operation/scripts/operation/ -maxdepth 1 -mindepth 1 -print |grep -v "\.swp" |
  local -r project_name="wispr-node-buildtools"
  local -r linux_project_path="${githubPath}/${project_name}"
  local -r linux_operation_path="${linux_project_path}/sandbox/buildroot/git/master/docker/operation/scripts/operation"
  local -r container_project_path=/usr/local/src/scripts/operation/
  local -r containerName="atlas-operation"

  cp  -fRpv ${linux_operation_path} ${host_githubPath}/

  echo "sync local into operation docker start.... linux_operation_path: ${linux_operation_path}"

  find ${linux_operation_path}/ -maxdepth 1 -mindepth 1 -print |_grep -v "\.swp" |xargs -L 1 -I % docker cp % ${containerName}:${container_project_path}/
  echo "sync local into operation docker done"
}

function debugSB {
  local -r linux_project_path="${githubPath}/wispr-node-buildtools/sandbox"
  local -r host_project_path="${host_githubPath}/sandbox"
  cp -fRpv ${linux_project_path}/package* ${host_project_path}/ && cp -fRpv ${linux_project_path}/sandbox.js ${host_project_path}/
  (\
    cd ${linux_project_path} && \
    node --inspect-brk=0.0.0.0:9246 ./sandbox.js -c init
  )
}

function debugBuild {
  local -r linux_project_path="${githubPath}/wispr-node-buildtools/build_docker_images"
  local -r host_project_path="${host_githubPath}/build_docker_images"
  mkdir -p ${host_project_path}
  (\
    cd ${linux_project_path} && \
    ls -A1 |grep -v node_modules |xargs -L 1 -I % cp -fRpv % ${host_project_path}/
    node --inspect-brk=0.0.0.0:9240 ./build.js
  )
}

function collectLog {
  local -r method=${1}
  local -r output_file="${host_githubPath}/logs/all.txt"


  if [ "${method:-}" = "collect" ]; then # to rename to tiantcbak
    echo "" > ${output_file}
    echo "ssl:" >> ${output_file}
    docker exec -it -u 0 atlas-ssl-0 cat /var/log/nginx/access.log >> ${output_file}
    echo "doad:" >> ${output_file}
    docker exec -it -u 0 atlas-doad-0 cat /var/log/api-gateway/api-gateway.log >> ${output_file}
    echo "files:" >> ${output_file}
    docker exec -it -u 0 atlas-files-0 cat /var/log/files-microservice/files-microservice.log >> ${output_file}
  else # to clear
    docker exec -it -u 0 atlas-ssl-0 sh -c 'echo "" > /var/log/nginx/access.log'
    docker exec -it -u 0 atlas-doad-0 sh -c 'echo "" > /var/log/api-gateway/api-gateway.log'
    docker exec -it -u 0 atlas-files-0 sh -c 'echo "" > /var/log/files-microservice/files-microservice.log'
  fi
}

# tail logs in container
function initK3d {
  kubectl exec -it -n ${namespace_default} atlas-api-gateway-0 -- sed -i 's/CORS_ALLOW_ALL: false/CORS_ALLOW_ALL: true/g' /usr/local/site/api-gateway/config/production.yml
  kubectl exec -it -n ${namespace_default} atlas-api-gateway-0 -- svc -du '/service/api-gateway/'
  kubectl exec -it -n ${namespace_default} atlas-ldapsync-0 -- sed -i "\$a arrangeSchedule: '*/30 * * * * *'\
\n\
syncSchedule: '*/10 * * * * *'" /usr/local/site/ldapsync-microservice/config/production.yml && \
  kubectl exec -it -n ${namespace_default} atlas-ldapsync-0 -- svc -du /service/ldapsync-microservice/
  kubectl exec -it -n ${namespace_default} atlas-ldapsync-0 -- cat /usr/local/site/ldapsync-microservice/config/production.yml
}


function login {
  curl 'https://api.k3d.atlashcl.com/api/authentication/login' \
    -H 'authority: api.k3d.atlashcl.com' \
    -H 'pragma: no-cache' \
    -H 'cache-control: no-cache' \
    -H 'accept: application/json, text/plain, */*' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36' \
    -H 'crossorigin: true' \
    -H 'content-type: application/json;charset=UTF-8' \
    -H 'origin: http://email.k3d.atlashcl.com' \
    -H 'sec-fetch-site: cross-site' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-dest: empty' \
    -H 'referer: http://email.k3d.atlashcl.com/auth/' \
    -H 'accept-language: en-US,en;q=0.9,zh;q=0.8,zh-CN;q=0.7,zh-TW;q=0.6' \
    --data-binary '{"username":"bpadmin@ops.k3d.atlashcl.com","password":"passw0rd"}' \
    --compressed \
    --insecure | python -c "import sys, json; print(json.load(sys.stdin)['data'][0]['token'])" \
    |& tee ./token.txt
}


# declare pvtTime=()
declare pvtTime="./pvtTime.txt"

function curlPVT {
  # in seconds
  local -r totalTime=2
  local -r totalRequests=1
  # local -r intervalSeconds=`echo "scale=3; ${totalTime}/${totalRequests}" | bc -l | awk '{printf "%.3f\n", $0}'`
  local -r intervalSeconds=0.001
  # echo "intervalSeconds: ${intervalSeconds}"

  # local -r token="$(login)"
  local -r token=`cat ./token.txt`
  local -r start=`date +%s%N`
  for i in `seq 1 1 ${totalRequests}`
  do
    echo "about to curl $i"
    curl -k 'https://api.k3d.atlashcl.com/api/files/batchMoveAsync' \
      -H 'authority: api.k3d.atlashcl.com' \
      -H 'pragma: no-cache' \
      -H 'cache-control: no-cache' \
      -H 'accept: application/json, text/plain, */*' \
      -H "authorization: ${token}" \
      -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36' \
      -H 'crossorigin: true' \
      -H 'content-type: application/json;charset=UTF-8' \
      -H 'origin: http://email.k3d.atlashcl.com' \
      -H 'sec-fetch-site: cross-site' \
      -H 'sec-fetch-mode: cors' \
      -H 'sec-fetch-dest: empty' \
      -H 'referer: http://email.k3d.atlashcl.com/files${i}' \
      -H 'accept-language: en-US,en;q=0.9,zh;q=0.8,zh-CN;q=0.7,zh-TW;q=0.6' \
      --data-binary '{"objects":["/bpadmin@ops.k3d.atlashcl.com/atlas-k3d-ops.yml","/bpadmin@ops.k3d.atlashcl.com/atlas-k3d-secret.yml"],"newPosition":"/bpadmin@ops.k3d.atlashcl.com/abc${i}/"}' \
      --compressed \
      --insecure &
##    sleep ${intervalSeconds}
  done
  local -r end=`date +%s%N`
#  totalTimeCost=`expr $end - $start`
#  echo Execution time was `nano2Readable ${totalTimeCost}`, intervalSeconds: ${intervalSeconds}.
  echo "${start},${end}" |& tee -a ${pvtTime}
}


function curlPVT_multiCore {
  echo "" > ${pvtTime}
  # login first
  login
  multipleCore 2 2 isDone curlPVT 2 3
  local -r array=(`cat ./pvtTime.txt`)
  declare -p array
  local declarestartArray=()
  local endArray=()

  for item in ${array[@]}; do
    local tmpArray=(`echo $item | tr ',' ' '`)
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
}

function doFunction {
  local -r start=`date +%s%N`
  echo "in doFunction" "$@"
  sleep 2
  echo "in doFunction" "$@" done
  local -r end=`date +%s%N`
  echo "${start},${end}" |& tee -a ${pvtTime}
}

function multipleCore {
  
  argu1=$1
  shift 1
  if [ "${argu1:-}" = "isDone" ] || [ "${argu1:-}" = "finalRound" ]; then
    functionName=$1
    shift 1
    ${functionName} "$@"
  else
    for i in `seq 1 1 ${argu1}`
    do
      multipleCore "$@" &
    done
    # wait for all background job completed, so that the paraent script(the caller) can know when all jobs are done
    wait
  fi

}

function collectFilesLog {
  local -r name=$1
  local -r allSummaryCSV='/opt/github/Atlas/sourcecode/results/s.csv'
  local -r sourcePath='/opt/github/Atlas/sourcecode/files.log'
  local -r targetSummary="/opt/github/Atlas/sourcecode/results/${name}.txt"
  local -r targetCSV="/opt/github/Atlas/sourcecode/results/${name}.csv"
  local -r tmpFile='/opt/github/Atlas/sourcecode/tmp.log'
  grep -Pzao "(?s)allData((?!allData).)+The file summary_(?!.*The file summary_.*)" ${sourcePath} > ${tmpFile}
  grep -Pzao "(?s)(?<=csvStr{\s\s)[^}]+(?=})" ${tmpFile} > ${targetCSV}
  grep -Pzao "(?s)resultMap.+submitCost.length: \d+\s+" ${tmpFile} > ${targetSummary}
  # find /opt/github/Atlas/sourcecode/results/ -mindepth 0 -maxdepth 0
  # "shortest time": "176, longest time is

  echo "generating summary.csv"
  echo "submit_short,submit_long,submit_mean,schedule_short,schedule_long,schedule_mean,file_short,file_long,filemean,total_short,total_long,total_mean" > ${allSummaryCSV}
  for file in /opt/github/Atlas/sourcecode/results/p*.txt; do
    echo "file: ${file}"
    local shortestTimes=(`grep -Pzao "(?s)(?<=shortest time)[^\d]+\K\d+," ${file} | tr ',' ' '`)
    local longestTimes=(`grep -Pzao "(?s)(?<=longest time is)[^\d]+\K\d+," ${file} | tr ',' ' '`)
    local meanTimes=(`grep -Pzao "(?s)(?<=mean time is)[^\d]+\K\d+," ${file} | tr ',' ' '`)
    for index in `seq 0 1 3`
     do
      echo -n "${shortestTimes[${index}]},${longestTimes[${index}]},${meanTimes[${index}]}," >> ${allSummaryCSV}
    done
    echo "" >> ${allSummaryCSV}
  done
  # clean the tailing comma
  sed -i 's/,$//g' ${allSummaryCSV}
}

# tail logs in container
function tailLog {
  # docker exec -it atlas-doad-0 tail -f /var/log/api-gateway/api-gateway.log
  docker exec -it atlas-files-0 tail -f /var/log/files-microservice/files-microservice.log
}

if [ "${_project:-}" = "api-gateway" ] || [ "${_project:-}" = "api" ]; then
  # reloadAPI_gateway ${_method} ${_param}
  reloadMicroSVC ${_method} ${_param} api-gateway true " common server package.json package-lock.json config " false
elif [ "${_project:-}" = "ldapsync" ] || [ "${_project:-}" = "syncldapsync" ]; then
  reloadLdapsync ${_method} ${_param}
elif [ "${_project:-}" = "batch" ] || [ "${_project:-}" = "batch-microservice" ]; then
  reloadMicroSVC ${_method} ${_param} batch true " src stub package.json package-lock.json config "
elif [ "${_project:-}" = "worker" ] || [ "${_project:-}" = "synWorker" ]; then
  # reloadWorker ${_method} ${_param}
  reloadMicroSVC ${_method} ${_param} worker true " src package.json package-lock.json config "
elif [ "${_project:-}" = "files-microservice" ] || [ "${_project:-}" = "files-svc" ] || [ "${_project:-}" = "files" ]; then
  # filesSVC ${_method} ${_param} 
  reloadMicroSVC ${_method} ${_param} files true " src package.json package-lock.json config "
elif [ "${_project:-}" = "renameSpec" ] || [ "${_project:-}" = "specUT" ]; then
  renameSpec ${_method} ${_param}
elif [ "${_project,,}" = "adminui" ] || [ "${_project:-}" = "admin" ] || [ "${_project:-}" = "citadel-control-panel" ]; then
  adminUI ${_method} ${_param}
elif [ "${_project:-}" = "atlas-ui" ] || [ "${_project,,}" = "atlasui" ]; then
  reloadAtlasUI ${_method} ${_param}
elif [ "${_project:-}" = "createBucket" ] || [ "${_project:-}" = "bucket" ]; then
  createBucket ${_method} ${_param}
elif [ "${_project:-}" = "addUser" ] || [ "${_project:-}" = "addDefaultUser" ]; then
  addDefaultUser ${_method} ${_param}
elif [ "${_project:-}" = "longerSession" ] || [ "${_project:-}" = "session" ]; then
  longerSession ${_method} ${_param}
elif [ "${_project:-}" = "clean" ] || [ "${_project:-}" = "cleanAll" ]; then
  cleanAll ${_method} ${_param}
elif [ "${_project:-}" = "operation" ] || [ "${_project:-}" = "removeOperation" ]; then
  removeOperation ${_method} ${_param}
elif [ "${_project:-}" = "syncOperation" ] || [ "${_project:-}" = "syncOperation" ]; then
  syncOperation ${_method} ${_param}
elif [ "${_project:-}" = "docker" ] || [ "${_project:-}" = "syncDocker" ]; then
  syncDockerRepo ${_method} ${_param}
elif [ "${_project:-}" = "sandbox" ] || [ "${_project:-}" = "debugSB" ]; then
  debugSB ${_method} ${_param}
elif [ "${_project:-}" = "build" ] || [ "${_project:-}" = "debugBuild" ]; then
  debugBuild ${_method} ${_param}
elif [ "${_project:-}" = "collectLog" ] || [ "${_project:-}" = "collect" ]; then
  collectLog ${_method} ${_param}
elif [ "${_project:-}" = "initK3d" ] || [ "${_project:-}" = "init" ]; then
  initK3d ${_method} ${_param}
elif [ "${_project:-}" = "login" ] || [ "${_project:-}" = "doLogin" ]; then
  login ${_method} ${_param}
elif [ "${_project:-}" = "curlPVT" ] || [ "${_project:-}" = "pvt" ]; then
  # multipleCore 2 2 2 isDone doFunction 2 3
  curlPVT_multiCore ${_method} ${_param}
elif [ "${_project:-}" = "collectFilesLog" ] || [ "${_project:-}" = "collectFiles" ]; then
  collectFilesLog ${_method} ${_param}
elif [ "${_project:-}" = "log" ] || [ "${_project:-}" = "tailLog" ]; then
  tailLog ${_method} ${_param}
elif [ "${_project:-}" = "test" ] || [ "${_project:-}" = "testFunction" ]; then
  echo "" > ${pvtTime}
  multipleCore 2 2 2 isDone doFunction 2 3
  wait
  echo "all are done"
  ls -AlpkFih ./
  echo "about to cat"
  cat ${pvtTime}
else
  echo "invalid project"
  exit 1
fi

echo "ret: ${ret}"
exit ${ret}

# to prune docker system
# docker system prune -f

# to clean up obsolete images
# PS: remember to replace your latest tag: master-HCLATLAS-file-service-HCLATLAS-file-service-1585030927927 -> "1585030927927"
#  docker images |grep -P "atlas\/" |grep -P "master-HCLATLAS-file-service-HCLATLAS-file-service-" |grep -v "1585030927927" |awk '{ print $3;}' |xargs -L 1 -I % docker rmi --force %

# to build wisper images on HCLATLAS-file-service
# ./build.js -b master -w HCLATLAS-file-service -d HCLATLAS-file-service

# tailLog
# docker exec -it atlas-doad-0 tail -f /var/log/api-gateway/api-gateway.log

# install webpack
# npm i webpack-cli webpack-bundle-analyzer  --save-dev


# way to mimic out of disk space {

# docker exec -it -u 0 atlas-files-0 sh -c "df -h && ls -AlpkFih /var/log/files-microservice && du -sh /var/log/files-microservice" && docker inspect atlas-files-0 |vim -

# docker cp /media/sf_github/tmp.tar atlas-files-0:/var/log/files-microservice/

# {{=<% %>=}}
# Image: "atlas/files:{{& env.version}}"
# ExposedPorts:
#   9254/tcp: {}
# HostConfig:
#   Privileged: true
#   NetworkMode: "{{& site.clusterName}}_vlan"
#   RestartPolicy:
#     Name: "no"
#   PortBindings:
#     9254/tcp:
#       - HostPort: "9254"
#   Binds:
#     - "sized_vol:/var/log/files-microservice/"
#}


# scrollBar in atlas {
#
#console.info(`scrollHeight: ${listScrollHeight}, scrollTop: ${listScrollTop}, clientHeight: ${listClientHeight}, offsetTop: ${listOffsetTop}, lastScrollTop: ${lastScrollTop}, previousAnchorPagesInSight: ${JSON.stringify(previousAnchorPagesInSight)}`);
#
#const allAnchors = document.getElementsByClassName('page-anchor');
#// at the beginning of every page(e.g. before item0, item20, item40, there will be an Anchor for page1, 2, 3)
#// and when this anchor is shown(visible) in current client window, it's anchorsInSight.
#// And if anchorsInSight is availabe after scrolling, then we'll switch to the page of that anchor.
#}

# to generate csv from json for i18n
# node /opt/github/Atlas/sourcecode/Atlas-Documents/tutorials/BlackboxScripts/UITranslationFormatConvert/index.js -ffi json -fpi /opt/github/Atlas/sourcecode/atlas-ui/public/locales/en-us/common.json -ffo csv -fpo /media/sf_github/tmp/a.csv

# docker path
# /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/base/docker
# /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker
# buildRoot: /opt/github/Atlas/sourcecode/wispr-node-buildtools/build_docker_images/../sandbox/buildroot/git/master, DATABAG_REPO_NAME: databag
# buildRoot: /opt/github/Atlas/sourcecode/wispr-node-buildtools/build_docker_images/../sandbox/buildroot/git/master, DOCKER_REPO_NAME: docker
# baseDockerPath: /opt/github/Atlas/sourcecode/wispr-node-buildtools/build_docker_images/../sandbox/buildroot/git/master/base, DOCKER_REPO_NAME: docker
# base: master, docker: master

# docker cp  /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker/operation/scripts/operation/performance.yml atlas-operation:/usr/local/src/scripts/operation/
# vi /usr/local/src/scripts/operation/performance.yml

# ssh -i ~/.ssh/mountain2.pem ubuntu@moutain02.atlahcl.com




# way to trigger ldapsync now
# docker exec -it atlas-ldapsync-0 \
#   sed -i "\$a arrangeSchedule: '*/30 * * * * *'\
#   \n\
# syncSchedule: '*/10 * * * * *'" /usr/local/site/ldapsync-microservice/config/production.yml && \
#  svc -du /service/ldapsync-microservice/
## kubectl version
# kubectl exec -it -n default atlas-ldapsync-0 -- \
#   sed -i "\$a arrangeSchedule: '*/30 * * * * *'\
#   \n\
# syncSchedule: '*/10 * * * * *'" /usr/local/site/ldapsync-microservice/config/production.yml && \
# kubectl exec -it -n default atlas-ldapsync-0 -- svc -du /service/ldapsync-microservice/

#######################To Allow all CORS[cors][allowCors]###############################   
#docker exec -it atlas-doad-1 sed -i 's/CORS_ALLOW_ALL: false/CORS_ALLOW_ALL: true/g' /usr/local/site/api-gateway/config/production.yml && \
#docker exec -it atlas-doad-1 svc -du '/service/api-gateway/'
#
#kubectl exec -it atlas-api-gateway-0 -- sed -i 's/CORS_ALLOW_ALL: false/CORS_ALLOW_ALL: true/g' /usr/local/site/api-gateway/config/production.yml && \
#kubectl exec -it atlas-api-gateway-0 -- svc -du '/service/api-gateway/'
#######################To reload Atlas-ui(Over)###############################
