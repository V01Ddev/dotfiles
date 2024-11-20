#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Adding git session
eval "$(ssh-agent -s)" > /dev/null 2>&1
ssh-add ~/.ssh/git > /dev/null 2>&1

# Adding $HOME/bin/ to PATH
export PATH="$HOME/bin:$PATH"

# Starting tmux
if command -v tmux > /dev/null 2>&1; then
  [ -z "$TMUX" ] && exec tmux
fi
