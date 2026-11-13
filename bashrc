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

# Ctrl-S is XOFF by default: it freezes terminal output until Ctrl-Q. Disable
# flow control so readline's own Ctrl-S binding works instead.
[[ -t 0 ]] && stty -ixon

# fzf default key bindings:
#   Ctrl-R    fuzzy history search
#   Ctrl-T    pick files/dirs under $PWD and insert their paths
#   Alt-C     pick a directory and cd into it
#   **<TAB>   fuzzy path completion
# Colors are ANSI indices 0-15, so they follow the terminal palette.
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --bash)
    # Ctrl-T, Alt-C and ** completion all inherit FZF_DEFAULT_OPTS, so the
    # walker skip list lives here once. Skipping caches/tool data keeps the
    # walker out of every cache under $HOME (~/.local alone is ~380k files).
    export FZF_DEFAULT_OPTS='--color=fg:7,bg:-1,hl:5,fg+:15,bg+:8,hl+:5,prompt:5,pointer:1,marker:1,info:2'
    export FZF_DEFAULT_OPTS+=' --walker-skip=.git,node_modules,.cache,.local,.cargo,.npm,.mozilla,.rustup,.steam'
    export FZF_DEFAULT_OPTS+=',.gradle,.m2,.venv,venv,.var,__pycache__,.fgfs,.arduino15,.pub-cache,.pyenv'
    export FZF_DEFAULT_OPTS+=',.wine,.wine-pyinstaller-32,.minecraft,.zoom,.codex,.claude,.BurpSuite'
    export FZF_DEFAULT_OPTS+=',.copilot,.docker,.gnupg,.thunderbird,.vscode,.vscode-oss'

    # Keep the Ctrl-T picker compact in short tmux panes.
    export FZF_CTRL_T_OPTS='--min-height=10'
fi

# opencode
export PATH=/home/v01d/.opencode/bin:$PATH
