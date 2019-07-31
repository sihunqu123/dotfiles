# .bashrc

echo "setup begin"
home=`cd ~ && pwd`


# const
bakDir="${home}/bakDir"
dotDir="${home}/.dotfiles"


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
  echo "$1" | grep -b -o "$2" | awk 'BEGIN {FS=":";RET=-1}{RET=$1} END {print RET}'
}

# return "true" if it's a link
function isLink {
  ret=$(ls -l "$1" |egrep "^l")
  echo "ret:${ret}"
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
  item2link=('.gitconfig' '.screenrc' '.bashrc' '.npmrc' '.vimrc' '.bash_profile' '.zshrc', '.vim/plugin/highlights.csv' '.vim/plugin/highlights.vim', '.vim/bundle/nerdtree/nerdtree_plugin/myMapping.vim')

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

if ((exitStatus==0)); then
 echo "setup successfully!"
else
 echo "setup failed!"
fi

# RET=$(lastIndexOf "a/bcb/de" "/")
# echo "last index: ${ret}" # output: 5

# echo "Setup vim-sensible plugin start..."
# cd ~/.vim/bundle && \
#   git clone https://github.com/tpope/vim-sensible.git
# echo "Setup vim-sensible plugin end."
