export CLICOLOR=1

export LSCOLORS=ExFxBxDxCxegedabagacad


alias gls='ls -AlpkFih --color=always'
alias sls='screen -ls'
alias vi='vim'

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# for ssh-agent to auth git automatically.
source ~/.config/.dotfiles/git_ssh.sh

# for k8s
export KUBE_EDITOR="vim"
# for helm
export HELM_HOST=:44134

# User specific environment and startup programs
echo "in ~/.dotfiles/.config/shell.sh"
# PATH=$PATH:$HOME/.local/bin:$HOME/bin
#PATH=$PATH:$HOME/.local/bin:$HOME/bin
#PATH=$HOME/bin:$HOME/.local/bin:$PATH
PATH=$HOME/.local/bin:$PATH:$HOME/bin

export PATH
