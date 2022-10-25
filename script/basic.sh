#!/bin/bash
# file testRunner.sh
# this file is called by ./launcher.sh
echo "in testRunner"


echo "BASH_SOURCE[0]: ${BASH_SOURCE[0]}"


# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

arg1="${1:-}"
arg2="${2:-}"
echo arg1: ${arg1} arg2: ${arg2} __dir: ${__dir} __file: ${__file} __base: ${__base} __root: ${__root}

# turn off expansion to avoid asterisk becoming current directory
set -f

# open debug opion during curl http operation so that details can be printed.
set -x

ret=1
# closed debug option.
set +x

exit ${ret}
# turn expansion back to 'on'
set +f
