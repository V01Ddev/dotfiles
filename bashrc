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

# Running tmux
if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
    exec tmux new-session -A -s ${USER} >/dev/null 2>&1
fi
