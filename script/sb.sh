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
declare -r nodeCommonUitlsPath="${githubPath}/node-common-utils"
declare -r nodeCommonUitlsLibPath="node_modules/@atlas/node-common-utils"

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
  local -r containerName="atlas-uiui-0"

  if [ -e ${linux_project_path}/dist/ ]; then
    echo "${linux_project_path}/dist/ exists"
  else 
    echo "Error: ${linux_project_path}/dist/ doesn't exists!!! Pls make sure generating build result in this folder."
    exit 2
  fi
  ls  -A1t  ${linux_project_path}/dist/*.hot-update.* |tail -n +4 | xargs -I % -L 1 rm -rfv %
  docker exec -it ${containerName} sh -c 'rm -rfv ${container_project_path}/*.hot-update.*'
  cp -fRpv ${linux_project_path}/{public/locales,dist/}
  find ${linux_project_path}/dist/ -maxdepth 1 -mindepth 1 -print |_grep -v "\.swp" |xargs -L 1 -I % docker cp % ${containerName}:${container_project_path}/
}

#
# reload files-svc, also copy linux src to host(overwrite), and then to the docker container
# @param 1: the method to do
# @param 2: whether need to launch with --inspect-brk. default --inspect
#
function filesSVC {
  local -r project_name="files-microservice"
  local -r linux_project_path="${githubPath}/${project_name}"
  local -r host_project_path="${host_githubPath}/${project_name}"
  local -r host_side_project_path="${host_side_githubPath}/${project_name}"
  local -r container_project_path=/usr/local/site/${project_name}
  local -r containerName="atlas-files-0"

  local -r method=${1}

  if [ "${method:-}" = "tar" ]; then # to tar node_modules/ files from container 
    docker exec -it ${containerName} sh -c "
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
    docker cp ${linux_project_path}/n2.tar ${containerName}:${container_project_path}/
    docker exec -it ${containerName} sh -c "
      cd ${container_project_path} &&
      tar xf n2.tar
    "
    cp -fRpv ${linux_project_path}/n2.tar ${host_project_path}/
    echo -e -n "please run:\n tar xf ${host_side_project_path}/n2.tar -C ${host_side_project_path}/\nin host's bash terminal.\n"
  else # to sync and restart
    local -r isBrk=${2}
    local -r inspectVal="inspect"

    if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
      inspectVal="inspect-brk"
    fi

    echo "about to reload debug "
    set +x
    find ${linux_project_path} -mindepth 1 -maxdepth 1 | _grep -Ev "/(config|.git|node_modules)$" |xargs -L 1 -I % sh -c "
      cp -fRpv % ${host_project_path} &&
      docker cp % ${containerName}:${container_project_path}
    "

    find ${nodeCommonUitlsPath}/ -mindepth 1 -maxdepth 1 | _grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % sh -c "
      mkdir -p ${linux_project_path}/${nodeCommonUitlsLibPath}/ && cp -fRpv % ${linux_project_path}/${nodeCommonUitlsLibPath}/ && 
      mkdir -p ${host_project_path}/${nodeCommonUitlsLibPath}/ && cp -fRpv % ${host_project_path}/${nodeCommonUitlsLibPath}/ && 
      docker cp % ${containerName}:${container_project_path}/${nodeCommonUitlsLibPath}/
    "
    docker exec -it ${containerName} bash -c "source /etc/profile
      cd ${container_project_path}/ && \
      export NODE_ENV=production && \
      svc -d /service/${project_name}/ && \
      node --inspect=0.0.0.0:9250 .
    "
  fi
}

#
# reload api-gatway, also copy linux src to host(overwrite), and then to the docker container
# @param 1: the method to do
# @param 2: whether need to launch with --inspect-brk. default --inspect
#
function reloadAPI-gateway {
  local -r linux_project_path="${githubPath}/api-gateway"
  local -r host_project_path="${host_githubPath}/api-gateway"
  local -r container_project_path="/usr/local/site/api-gateway"
  local -r containerName="atlas-doad-0"

  local -r isBrk=${2}
  local -r inspectVal="inspect"

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
  find ${nodeCommonUitlsPath}/ -mindepth 1 -maxdepth 1 |_grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % sh -c "
    mkdir -p ${linux_project_path}/${nodeCommonUitlsLibPath}/ && cp -fRpv % ${linux_project_path}/${nodeCommonUitlsLibPath}/ && 
    mkdir -p ${host_project_path}/${nodeCommonUitlsLibPath}/ && cp -fRpv % ${host_project_path}/${nodeCommonUitlsLibPath}/ && 
    docker cp % ${containerName}:${container_project_path}/${nodeCommonUitlsLibPath}/
  "
  docker exec -it ${containerName} bash -c "source /etc/profile
    cd ${container_project_path}/ && \
    export NODE_ENV=production && \
    svc -d /service/api-gateway/ && \
    node --${inspectVal}=0.0.0.0:9229 .
  "
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
  docker exec -it -u 0 atlas-operation sh -c 'node /usr/local/src/scripts/operation/admin.js addDefaultUsers'
}

# change the session timeout to a longer time

# the unit of this SESSION_INACTIVE_TIMEOUT is:
#   expire
#   Expiration time of the item. If it's equal to zero, the item will never expire. You can also use Unix timestamp or a number of seconds starting from current time, but in the latter case the number of seconds may not exceed 2592000 (30 days).
# refer: https://stackoverflow.com/questions/6027517/can-the-time-to-live-ttl-for-a-memcached-key-be-set-to-infinite
function longerSession {
  # docker exec -it atlas-authen-0 sed -i 's/SESSION_INACTIVE_TIMEOUT =[^;]\+;/SESSION_INACTIVE_TIMEOUT = 999999;/g' /usr/local/site/authen-microservice/src/common/utils.js
  docker exec -it atlas-authen-0 sed -i 's/SESSION_INACTIVE_TIMEOUT =[^;]\+;/SESSION_INACTIVE_TIMEOUT = 0;/g' /usr/local/site/authen-microservice/src/common/utils.js
  docker exec -it atlas-authen-0 svc -du '/service/authen-microservice/'
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
#
#   
#   for fileFullPath in ${linux_project_path}/.tmp/assets/{env.js,theme.scss,theme.js}; do
#      
#   done
    cp -fRpv ${linux_project_path}/.tmp/assets/env.js ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.env.js
    cp -fRpv ${linux_project_path}/.tmp/assets/theme.scss ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.theme.css
    cp -fRpv ${linux_project_path}/.tmp/assets/theme.js ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.theme.js
    cp -fRpv ${linux_project_path}/.tmp/assets/env.js ${linux_project_path}/.tmp/assets/local.atlas.com.cobrand.env.js

    # remove remote old files
    docker exec -it atlas-uiui-0 rm -rfv ${container_project_path}/admin
    # cp local new files to remote
    docker cp ${linux_project_path}/.tmp/ ${containerName}:${container_project_path}/admin
         
##  docker cp /opt/github/Atlas/sourcecode/citadel-control-panel/.tmp/app.js atlas-uiui-0:/usr/local/site/citadel-control-panel/admin/
##  docker cp /opt/github/Atlas/sourcecode/citadel-control-panel/.tmp/app.js.map atlas-uiui-0:/usr/local/site/citadel-control-panel/admin/
##  docker cp /opt/github/Atlas/sourcecode/citadel-control-panel/.tmp/index.html atlas-uiui-0:/usr/local/site/citadel-control-panel/admin/
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

function debugSB {
  local -r linux_project_path="${githubPath}/wispr-node-buildtools/sandbox"
  local -r host_project_path="${host_githubPath}/sandbox"
  cp -fRpv ${linux_project_path}/package* ${host_project_path}/ && cp -fRpv ${linux_project_path}/sandbox.js ${host_project_path}/
  (\
    cd ${linux_project_path} && \
    node --inspect-brk=0.0.0.0:9241 ./sandbox.js -c init
  )
}

# tail logs in container
function tailLog {
  # docker exec -it atlas-doad-0 tail -f /var/log/api-gateway/api-gateway.log
  docker exec -it atlas-files-0 tail -f /var/log/files-microservice/files-microservice.log
}

if [ "${_project:-}" = "api-gateway" ] || [ "${_project:-}" = "api" ]; then
  reloadAPI-gateway ${_method} ${_param}
elif [ "${_project:-}" = "files-microservice" ] || [ "${_project:-}" = "files-svc" ] || [ "${_project:-}" = "files" ]; then
  filesSVC ${_method} ${_param}
elif [ "${_project:-}" = "renameSpec" ] || [ "${_project:-}" = "specUT" ]; then
  renameSpec ${_method} ${_param}
elif [ "${_project:-}" = "adminUI" ] || [ "${_project:-}" = "admin" ] || [ "${_project:-}" = "citadel-control-panel" ]; then
  adminUI ${_method} ${_param}
elif [ "${_project:-}" = "atlas-ui" ] || [ "${_project:-}" = "ui" ]; then
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
elif [ "${_project:-}" = "sandbox" ] || [ "${_project:-}" = "debugSB" ]; then
  debugSB ${_method} ${_param}
elif [ "${_project:-}" = "log" ] || [ "${_project:-}" = "tailLog" ]; then
  tailLog ${_method} ${_param}
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



# scrollBar in atlas {
#
#console.info(`scrollHeight: ${listScrollHeight}, scrollTop: ${listScrollTop}, clientHeight: ${listClientHeight}, offsetTop: ${listOffsetTop}, lastScrollTop: ${lastScrollTop}, previousAnchorPagesInSight: ${JSON.stringify(previousAnchorPagesInSight)}`);
#
#const allAnchors = document.getElementsByClassName('page-anchor');
#// at the beginning of every page(e.g. before item0, item20, item40, there will be an Anchor for page1, 2, 3)
#// and when this anchor is shown(visible) in current client window, it's anchorsInSight.
#// And if anchorsInSight is availabe after scrolling, then we'll switch to the page of that anchor.
#}

# docker path
# /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/base/docker
# /opt/github/Atlas/sourcecode/wispr-node-buildtools/sandbox/buildroot/git/master/docker
# buildRoot: /opt/github/Atlas/sourcecode/wispr-node-buildtools/build_docker_images/../sandbox/buildroot/git/master, DATABAG_REPO_NAME: databag
# buildRoot: /opt/github/Atlas/sourcecode/wispr-node-buildtools/build_docker_images/../sandbox/buildroot/git/master, DOCKER_REPO_NAME: docker
# baseDockerPath: /opt/github/Atlas/sourcecode/wispr-node-buildtools/build_docker_images/../sandbox/buildroot/git/master/base, DOCKER_REPO_NAME: docker
# base: master, docker: master

# ssh -i ~/.ssh/mountain2.pem ubuntu@moutain02.atlahcl.com
