
# return "true" if it's macos
function isMacOS {
  ret=$(uname |egrep "^Darwin")
#   echo "ret:${ret}"
  [[ ! -z "${ret}" ]] && echo "true" || echo "false"
}


