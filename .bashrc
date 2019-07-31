# .bashrc

echo "in ~/.bashrc"

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w \$ "
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ \[\033[m\]"


bind Space:magic-space

. ~/.dotfiles/.config/shell.sh


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
