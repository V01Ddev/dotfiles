#
# ~/.bash_profile
#

# Load ~/.bashrc for interactive features 
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Environment Variables (Moved from bashrc) 
export PATH="$HOME/bin:/usr/local/texlive/2025/bin/x86_64-linux:$PATH"
export MANPATH="/usr/local/texlive/2025/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/usr/local/texlive/2025/texmf-dist/doc/info:$INFOPATH"
export MANPAGER='nvim +Man!'

# SSH Key Management 
if command -v keychain > /dev/null 2>&1; then
    eval $(keychain --quiet --eval ~/.ssh/git ~/.ssh/work_github)
fi
