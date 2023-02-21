
# return "true" if it's macos
function isMacOS {
  ret=$(uname |egrep "^Darwin")
#   echo "ret:${ret}"
  [[ ! -z "${ret}" ]] && echo "true" || echo "false"
}

function isLinux {
  ret=$(uname |egrep "Linux")
#   echo "ret:${ret}"
  [[ ! -z "${ret}" ]] && echo "true" || echo "false"
}


function exitIfError {
  if (($1==0)); then
    echo "no error found yet"
  else
    echo "Error found! Exit..."
    exit 1
  fi
}


