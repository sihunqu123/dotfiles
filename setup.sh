#!/bin/bash

echo "setup begin"
home=`cd ../ && pwd`

set -x

# .bashrc
# const
bakDir="${home}/bakDir"
dotDir="${home}/.dotfiles"

source ./utils/commonUtil.sh

shopt -s expand_aliases

declare -r uname=$(uname)
declare currentOS=""

echo "uname=${uname}"

case "$uname" in
    (*Linux*) currentOS='Linux';
              echo "OS is Linux"
              alias _grep="grep"
              ;;
    (*Darwin*) currentOS='Darwin';
              echo "OS is MacOS."
              if command -v ggrep &> /dev/null
              then
                echo "[checked] GNU utils is install, ready to run"
                alias grep="ggrep"
                alias sed="gsed"
              else
                echo "Error: pls make sure ggrep(the GNU grep) is install. Tips: run
                brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt
                For details, pls refer to:
                  https://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities"
                exit 2;
              fi
              ;;
    (*CYGWIN*) currentOS='windows';
              echo "OS is CYGWIN"
              alias _grep="grep"
              ;;
    (*MINGW64*) currentOS='windows';
              echo "OS is MINGW64"
              alias _grep="grep"
              ;;
#   (*) echo 'error: unsupported platform.'; exit 2; ;;
# fallback to CYGWIN
    (*) currentOS='windows';
              echo "OS is CYGWIN"
              alias _grep="grep"
              ;;
esac;

echo "bakDir: ${bakDir}"
$(mkdir ${bakDir})
if [ -e $bakDir ]; then
  echo "bakDir already exists, exit."
else
  echo "bakDir not exists, will create it."
  mkdir ${bakDir}
fi

# return -1 if not found
function lastIndexOf {
  echo "$1" | grep -b -o "$2" | awk 'BEGIN {FS=":";RET=-1}{RET=$1} END {print RET}'
}
# ret=$(lastIndexOf "a/bcb/de" "/")
# echo "last index: ${ret}" # output: 5

# ret=$(lastIndexOf "a/bcb/de" "/")
# echo "last index: ${ret}" # output: 5

if [ -e "${home}/.vim/bundle/Vundle.vim" ]; then
  echo "seems vundle is already installed"
else
  echo "vundle not installed yet, will install it first"
  git clone https://github.com/VundleVim/Vundle.vim.git "${home}/.vim/bundle/Vundle.vim"
fi


# return "true" if it's a link
function isLink {
  ret=$(ls -l "$1" |egrep "^l")
#  echo "ret:${ret}"
  [[ ! -z "${ret}" ]] && echo "true" || echo "false"
}

function linkFrmDot {
  fileInHome="${home}/$1"
  # bakup first
  if [ -e $fileInHome ]; then
    echo "$fileInHome exits"
    ret=$(isLink "${fileInHome}")
    if [[ "${ret}" == "true" ]]; then
      echo "but is a link, thus will remove it."
      rm -fv ${fileInHome}
    else
      echo "and is not a link, thus, will move it to ${bakDir}"
      # use cp for test
      mv -fv ${fileInHome} ${bakDir}/
      # cp -fRpv $fileInHome ${bakDir}/
    fi
  else
    echo "$fileInHome doesn't exits, skip"
  fi
  # bakup done, then link from dotfiles
  slashPosition=$(lastIndexOf "$1" "/")
  # if slashPosition < 0
  if [ $slashPosition -lt 0 ]; then
    echo "slashPosition:${slashPosition} < 0. It's in home root path, thus no need to make dir"
  else
    echo "slashPosition:${slashPosition} > 0."
    dirPath=${home}/${1:0:${slashPosition}}
    echo "dirPath: ${dirPath} to mkdir"
    if [ -e ${dirPath} ]; then
      echo "dir: ${dirPath} already exists, no need to mkdir"
    else
      echo "dir: ${dirPath} doesn't exists, need to mkdir"
      mkdir -pv ${dirPath}
    fi
  fi

  fileInDotFile="${dotDir}/$1"

# ln -sv ${fileInDotFile} ${fileInHome}
  cp -fRpv ${fileInDotFile} ${fileInHome}

# if [ -d ${fileInDotFile} ]; then
#   echo "${fileInDotFile} is folder"
#   if [[ ${currentOS} == "windows" ]]; then
#     echo "${fileInDotFile} - os is windows"
#     cp -fRpv ${fileInDotFile} ${fileInHome}
#   else
#     echo "${fileInDotFile} - os is not windows"
#     ln -sv ${fileInDotFile} ${fileInHome}
#   fi
# else
#   echo "${fileInDotFile} is a file"
#   ln -sv ${fileInDotFile} ${fileInHome}
# fi
}

function setup {
  echo "script folder creating..."
  mkdir ${home}/script ;
  echo "script folder created"

  item2link=(
    '.gitconfig' '.screenrc' '.bashrc' '.npmrc' '.vimrc' '.bash_profile'
    '.zshrc' '.vim/plugin/highlights.csv' '.vim/plugin/highlights.vim'
    '.vim/colors/molokai.vim' '.vim/colors/SolarizedDark.vim' '.vim/tiantccs.vim'
    'script'
  )

  length=${#item2link[@]}

  for(( i=0;i<$length;i++)); do
    item=${item2link[${i}]}
    echo "item: ${item} i: ${i}"
    linkFrmDot "${item}"
  done
}

# call setup
setup
exitStatus=$?
exitIfError exitStatus

vim +PluginInstall +qall

# Should be executed after `PluginInstall`, otherwise nerdtree won't be installed.
linkFrmDot '.vim/bundle/nerdtree/nerdtree_plugin/myMapping.vim'


exitStatus=$?
exitIfError exitStatus

function exitIfError {
  if (($1==0)); then
    echo "setup successfully!"
    echo "Please DO remember to install fzf(u have how to do that in your notes)"
  else
    echo "setup failed!"
    exit 1
  fi
}
# echo "Setup vim-sensible plugin start..."
# cd ${home}/.vim/bundle && \
#   git clone https://github.com/tpope/vim-sensible.git
# echo "Setup vim-sensible plugin end."





# cygwin usage
# ln -s /cygdrive/c /c
# ln -s /cygdrive/d /d
# ln -s /cygdrive/e /e
# mv -fv /home/chen.tian /home/chen.tian_
# ln -s /c/Users/chen.tian/ /home/chen.tian
# ln -s /c/Users/chen.tian/ /home/tiantc
