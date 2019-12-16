REPO_PATH=/opt/github/Atlas/sourcecode/sandbox/buildroot/repodir/repodir/ym_package/master/noarch/
verified_file_path=/home/tiantc/script/template.verified

cd /home/tiantc/tmp/rpm/

arg1="${1:-}"
arg2="${2:-}"
echo arg1: ${arg1} arg2: ${arg2}

mwget -n 10 ${arg1}

/home/tiantc/.dotfiles/script/copyRpm.sh ${arg2}
