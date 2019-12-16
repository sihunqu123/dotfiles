REPO_PATH=/opt/github/Atlas/sourcecode/sandbox/buildroot/repodir/repodir/ym_package/master/noarch/
verified_file_path=/home/tiantc/script/template.verified

arg1="${1:-}"

cd /home/tiantc/tmp/rpm/

# first rename download filename to formal filename
files=$(ls -A1 /home/tiantc/tmp/rpm/ |grep '"')
origin_IFS=$IFS
IFS=$'\n'
# files=aa,bb,cc
for filename in ${files}
do
  echo "filename: ${filename}"
  filename_new=$(echo ${filename} |grep -oP '(?<=")[^"]+(?=")')
  echo "filename_new: ${filename_new}"
  filename_old=$(echo ${filename} | sed 's/"/\\"/g')
  echo "filename_old: ${filename_old}"
  mv -fv "${filename}" "${filename_new}"
done

IFS=$origin_IFS

# then copy rpm and it's verified file to repo

files=$(ls -A1 /home/tiantc/tmp/rpm/ |egrep '.rpm$')
origin_IFS=$IFS
IFS=$'\n'
# files=aa,bb,cc
for filename in ${files}
do
  echo "filename: ${filename}"
  mv -fv "${filename}" "${arg1}"
#   cp -fRpv "${verified_file_path}" "${REPO_PATH}${filename}.verified"
done

IFS=$origin_IFS

# IFS=$'\n', read -ra ffs <<< $(ls -AN1 /home/tiantc/tmp/rpm/)
# for filename in "${ffs[@]}"
# do
#   echo "filename: ${filename}"
# done

# echo "after"
# 
# for filename in ${files}
# do
#   echo "filename: ${filename}"
# done
