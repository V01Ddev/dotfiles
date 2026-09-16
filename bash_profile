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

# Deepseek with claude
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"

# The auth token lives outside this repo (~/.anthropic-token, chmod 600) so it
# never gets committed. That file holds one line:
#   export ANTHROPIC_AUTH_TOKEN="..."
if [ -f "$HOME/.anthropic-token" ]; then
    . "$HOME/.anthropic-token"
fi

export ANTHROPIC_MODEL="deepseek-flash[1m]"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-flash[1m]"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-flash[1m]"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-flash"

export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="786432"

# SSH Key Management
if command -v keychain > /dev/null 2>&1; then
    eval "$(keychain add --eval --quiet --immediate ~/.ssh/git ~/.ssh/work_github)"
fi
