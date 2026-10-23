#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='ls --color=auto -F'
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '

export PATH="$HOME/.local/bin:$PATH"

# Command-aware Tab completion (Arch loads this system-wide; sourced explicitly
# so this file also works on distros that don't)
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
fi

# fzf: fuzzy path completion with `**<TAB>`, plus Ctrl-R history and Ctrl-T
# file picker. Colors are ANSI indices 0-15, so they follow the terminal palette.
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --bash)
    export FZF_DEFAULT_OPTS='--color=fg:7,bg:-1,hl:5,fg+:15,bg+:8,hl+:5,prompt:5,pointer:1,marker:1,info:2'
fi
