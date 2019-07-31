# .bashrc

echo "setup begin"
home=`cd ~ && pwd`


# const
bakDir="${home}/bakDir"
dotDir="${home}/.dotfiles"

GREP_CLI='grep'

source ./utils/commonUtil.sh

isMacOS_b=$(isMacOS)
# set grep command line tool
if [[ "${isMacOS_b}" == "true" ]]; then
  # for macos, use ggrep instead
  which ggrep > /dev/null
  exitStatus=$?
  if ((exitStatus==0)); then
    # echo "use ggrep instead."
    GREP_CLI='ggrep'
  else
    # echo "Setup failed! ggrep is needed! Please install gnu grep."
    exit 1
  fi
else
  # for centos7 and Windows, nothing to do
  echo "grep is OK"
fi

echo "bakDir: ${bakDir}"
$(mkdir ${bakDir})
if [ -e $bakDir ]; then
  echo "bakDir already exists, exit."
else
  echo "bakDir not exists, will create it."
  mkdir ${bakDir}
fi

# return -1 if not found
function lastIndexOf() {
  echo "$1" | ${GREP_CLI} -b -o "$2" | awk 'BEGIN {FS=":";RET=-1}{RET=$1} END {print RET}'
}
# ret=$(lastIndexOf "a/bcb/de" "/")
# echo "last index: ${ret}" # output: 5

if [ ! -e "${home}/.bashrc" ]; then
  echo "seems vundle is already installed"
else
  echo "vundle not installed yet, will install it first"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
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
      mv -fv $fileInHome ${bakDir}/
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
  ln -sv ${fileInDotFile} ${fileInHome}
}

function setup {
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
  else
    echo "setup failed!"
    exit 1
  fi
}

# echo "Setup vim-sensible plugin start..."
# cd ~/.vim/bundle && \
#   git clone https://github.com/tpope/vim-sensible.git
# echo "Setup vim-sensible plugin end."
