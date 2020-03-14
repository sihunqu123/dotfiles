#!/bin/bash

echo "in sb launcher"


#set -o errexit
#set -o pipefail
#set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
declare -r __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
declare -r __base="$(basename ${__file} .sh)"
declare -r __root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

declare -r githubPath="/opt/github/Atlas/sourcecode"
declare -r host_githubPath="/media/sf_github"
declare -r host_side_githubPath="/d/github"
declare -r nodeCommonUitlsPath="${githubPath}/node-common-utils"
declare -r nodeCommonUitlsLibPath="node_modules/@atlas/node-common-utils"


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
  local -r containerName="atlas-uiui-1"

ls  -A1t  ${linux_project_path}/dist/*.hot-update.* |tail -n +4 | xargs -I % -L 1 rm -rfv % && \
  docker exec -it ${containerName} sh -c 'rm -rfv ${container_project_path}/*.hot-update.*' && \
  cp -fRpv ${linux_project_path}/{public/locales,dist/} && \
  find ${linux_project_path}/dist/ -maxdepth 1 -mindepth 1 -print |grep -v "\.swp" |xargs -L 1 -I % docker cp % ${containerName}:${container_project_path}/
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
  local -r containerName="atlas-files-1"

  local -r method=${1}

  if [ "${method:-}" = "tar" ]; then # to tar node_modules/ files from container 
    docker exec -it ${containerName} sh -c "
      cd ${container_project_path} &&
      tar cf n.tar node_modules/
    " && \
    docker cp ${containerName}:${container_project_path}/n.tar ${linux_project_path}/ && \
      tar xf n.tar && \
      cp -fRpv n.tar ${host_project_path}/ && \
      echo -e -n "please run:\n tar xf ${host_side_project_path}/n.tar -C ${host_side_project_path}/\nin host's bash terminal.\n"
  elif [ "${method:-}" = "push" ]; then # push local node_moudles to conainer
    (\
      cd ${linux_project_path} && \
      tar cf n2.tar node_modules/ \
    ) && \
    docker cp ${linux_project_path}/n2.tar ${containerName}:${container_project_path}/ && \
    docker exec -it ${containerName} sh -c "
      cd ${container_project_path} &&
      tar xf n2.tar
    " && \
    cp -fRpv ${linux_project_path}/n2.tar ${host_project_path}/ && \
    echo -e -n "please run:\n tar xf ${host_side_project_path}/n2.tar -C ${host_side_project_path}/\nin host's bash terminal.\n"
  else # to sync and restart
    local -r isBrk=${2}
    local -r inspectVal="inspect"

    if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
      inspectVal="inspect-brk"
    fi

    echo "about to reload debug "
    find ${linux_project_path} -mindepth 1 -maxdepth 1 |egrep -v "/(config|.git|node_modules)$" |xargs -L 1 -I % \
        sh -c "cp -fRpv % ${host_project_path} && docker cp % ${containerName}:${container_project_path}" && \
      find ${nodeCommonUitlsPath}/ -mindepth 1 -maxdepth 1 |grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % \
        sh -c "
          cp -fRpv % ${linux_project_path}/${nodeCommonUitlsLibPath}/ && 
          cp -fRpv % ${host_project_path}/${nodeCommonUitlsLibPath}/ && 
          docker cp % ${containerName}:${container_project_path}/${nodeCommonUitlsLibPath}/
        " && \
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
  local -r containerName="atlas-doad-1"

  local -r isBrk=${2}
  local -r inspectVal="inspect"

  if [ "${isBrk:-}" = "true" ] || [ "${isBrk:-}" = "1" ]; then
    inspectVal="inspect-brk"
  fi

  echo "about to reload debug "
  docker exec -it ${containerName} svc -d /service/api-gateway && \
    cp -fRpv ${linux_project_path}/common ${linux_project_path}/server ${linux_project_path}/package.json ${linux_project_path}/package-lock.json ${linux_project_path}/config  ${host_project_path}/ && \
    docker cp ${linux_project_path}/common ${containerName}:${container_project_path}/ && \
    docker cp ${linux_project_path}/server ${containerName}:${container_project_path}/ && \
    docker cp ${linux_project_path}/config ${containerName}:${container_project_path}/ && \
    docker cp ${linux_project_path}/package.json ${containerName}:${container_project_path}/ && \
    docker cp ${linux_project_path}/package-lock.json ${containerName}:${container_project_path}/ && \
    find ${nodeCommonUitlsPath}/ -mindepth 1 -maxdepth 1 |grep -P "(\/lib|src|.json)$" |xargs -L 1 -I % \
      sh -c "
        cp -fRpv % ${linux_project_path}/${nodeCommonUitlsLibPath}/ && 
        cp -fRpv % ${host_project_path}/${nodeCommonUitlsLibPath}/ && 
        docker cp % ${containerName}:${container_project_path}/${nodeCommonUitlsLibPath}/
      " && \
    docker exec -it ${containerName} bash -c "source /etc/profile
      cd ${container_project_path}/ && \
      export NODE_ENV=production && \
      svc -d /service/api-gateway/ && \
      node --${inspectVal}=0.0.0.0:9229 .
    "
}

if [ "${_project:-}" = "api-gateway" ] || [ "${_project:-}" = "api" ]; then
  reloadAPI-gateway ${_method} ${_param}
elif [ "${_project:-}" = "files-microservice" ] || [ "${_project:-}" = "files-svc" ] || [ "${_project:-}" = "files" ]; then
  filesSVC ${_method} ${_param}
elif [ "${_project:-}" = "atlas-ui" ] || [ "${_project:-}" = "ui" ]; then
  reloadAtlasUI ${_method} ${_param}
else 
  echo "invalid project"
  exit 1
fi

echo "ret: ${ret}"
exit ${ret}

