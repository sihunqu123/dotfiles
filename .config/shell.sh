#!/bin/bash
source ~/.dotfiles/utils/commonUtil.sh

isMacOS_b=$(isMacOS)

export CLICOLOR=1

export LSCOLORS=ExFxBxDxCxegedabagacad

PATH=~/npm/bin:$PATH

if [[ "${isMacOS_b}" == "true" ]]; then
  # for macos
  alias gls='ls -AGlpkFihO'
  # some macos settings
  # Setting PATH for Python 3.6
  # The original version is saved in .bash_profile.pysave
  # PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}:/Users/tiantc/Library/Python/3.6/bin"
  # Setting PATH for Python 3.8
  PATH="/Library/Frameworks/Python.framework/Versions/3.8/bin:${PATH}:/Users/tiantc/Library/Python/3.8/bin"
  # change  ruby version to build command-t
  PATH="/usr/local/Cellar/ruby/2.6.2/bin:${PATH}"
else
  # for centos7 and Windows
  alias gls='ls -AlpkFih --color=always'
fi

alias sls='screen -ls'
alias vi='vim'

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# for ssh-agent to auth git automatically.
source ~/.dotfiles/.config/git_ssh.sh

# for k8s
export KUBE_EDITOR="vim"
# for helm
export HELM_HOST=:44134

# User specific environment and startup programs
echo "in ~/.dotfiles/.config/shell.sh"
# PATH=$PATH:$HOME/.local/bin:$HOME/bin
#PATH=$PATH:$HOME/.local/bin:$HOME/bin
#PATH=$HOME/bin:$HOME/.local/bin:$PATH
#PATH=$HOME/.local/bin:$PATH:$HOME/bin
PATH=$HOME/.local/bin:$PATH:$HOME/bin:$HOME/go/bin

export PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# LANG="en_US.UTF-8"
# LC_COLLATE="en_US.UTF-8"
# LC_CTYPE="en_US.UTF-8"
# LC_MESSAGES="en_US.UTF-8"
# LC_MONETARY="en_US.UTF-8"
# LC_NUMERIC="en_US.UTF-8"
# LC_TIME="en_US.UTF-8"
# LC_ALL="en_US.UTF-8"
# 
# echo "about to locale"
# locale
