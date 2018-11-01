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


function linkFrmDot {
  fileInHome="${home}/$1"
  # bakup first
  if [ -e $fileInHome ]; then
    echo "$fileInHome exits, will move it to ${bakDir}" 
    # use cp for test
    mv -fv $fileInHome ${bakDir}/
    # cp -fRpv $fileInHome ${bakDir}/
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
  item2link=('.config/git' '.gitattributes' '.gitconfig' '.screenrc' '.bashrc' '.npmrc' '.vimrc')

  length=${#item2link[@]}

  for(( i=0;i<$length;i++)); do
    item=${item2link[${i}]}
    echo "item: ${item} i: ${i}"
    linkFrmDot "${item}"
  done
}

echo "IFS: ${IFS}"

IFS=';' read -ra ADDR <<< "aa;bb;cc"
for i in "${ADDR[@]}"; do
    # process "$i"
    echo "i: ${i} , IFS: ${IFS}"
done


echo "IFS: ${IFS}"

# call setup
setup


function arrTest {
  item2link=('.config/git' '.gitattributes')
  for item in ${item2link[@]}; do
    echo "item: ${item}"
    linkFrmDot "${item}"
  done
}

# arrTest


ret=$(lastIndexOf "a/bcb/de" "/")
echo "last index: ${ret}" # output: 5

# bakup ~/.config/git
# bakup ~/.gitattributes
# bakup ~/.gitconfig
# bakup ~/.screenrc
# bakup ~/.bashrc
# bakup ~/.npmrc
# bakup ~/.vimrc
