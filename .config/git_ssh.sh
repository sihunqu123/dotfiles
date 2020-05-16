
# echo "currently no git ssh sock needed!"
echo "About to initialize ssh auth agent"

echo "ssh_auth_sock:"
echo "$SSH_AUTH_SOCK"
function createSSHAgent() {
    echo "about to ssh-agent"
    eval `ssh-agent`
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
}

if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  # call createSSHAgent functio
  createSSHAgent
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
ssh-add -l || ssh-add

ret=$?
echo "ret: ${ret}"
## if ret is greater than 1
if [ "${ret}" -gt 1 ]; then
        echo "no available ssh_auth_sock, will remove it"
        rm -rfv ~/.ssh/ssh_auth_sock
        echo "ssh_auth_sock deleted, will create a new one"
        createSSHAgent
        export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
        echo "ssh_auth_sock created, connecting to it...."
        ssh-add -l || ssh-add
        ret=$?
        echo "ret: ${ret}"
        if [ "${ret}" -gt 1 ]; then
                echo "connect to ssh_agent failed! stop trying"
        else
                echo "connect to ssh_agent successfully!"
        fi
else
## else the ret is  not greater than 1
        echo "connect to ssh_agent successfully!"
fi

echo "after ssh-agent"
