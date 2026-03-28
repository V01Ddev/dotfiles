#
# ~/.bashrc
#

# If not running interactively, don't do anything 
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto -F' 
alias grep='grep --color=auto' 

PS1='[\u@\h \W]\$ ' 
