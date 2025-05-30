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

# Making man open pages in nvim
export MANPAGER='nvim +Man!'

# Starting tmux
#if command -v tmux > /dev/null 2>&1; then
#  [ -z "$TMUX" ] && exec tmux
#fi

# Tmux alias
tmuxn() {
    if [ -z "$1" ]; then
        tmux new-session -d
    else
        tmux new-session -d -s "$1"
    fi
}
