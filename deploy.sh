#!/usr/bin/env bash
# Print the packages still missing on this machine and symlink this repo's
# config files into $HOME.
#
# Nothing is installed and no config is copied: existing files are moved to
# <name>.bak.<timestamp> before the symlink is created, and the script is safe
# to re-run.
#
# ~/.ssh/config and ~/.gitconfig-work are intentionally not linked. They hold
# machine-specific values (key paths, work identity) and this repo is public,
# so copy their templates by hand and edit the local copies.

set -euo pipefail

DOTFILES="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

packages_arch=(
    git base-devel bash-completion fzf keychain tmux neovim ripgrep fd
    noto-fonts ttf-hack konsole
)
packages_debian=(
    git build-essential bash-completion fzf keychain tmux ripgrep fd-find
    fonts-noto-core fonts-hack fontconfig konsole
)

print_packages() {
    local missing=() p

    if command -v pacman >/dev/null 2>&1; then
        for p in "${packages_arch[@]}"; do
            if [ "$p" = base-devel ]; then
                if ! command -v gcc >/dev/null 2>&1 || ! command -v make >/dev/null 2>&1; then
                    missing+=("$p")
                fi
            elif ! pacman -Qq "$p" >/dev/null 2>&1; then
                missing+=("$p")
            fi
        done
        echo "Missing Arch packages:"
        if [ "${#missing[@]}" -eq 0 ]; then
            echo "  (none)"
        else
            printf '  %s\n' "${missing[@]}"
            echo
            echo "  sudo pacman -S --needed ${missing[*]}"
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        for p in "${packages_debian[@]}"; do
            if ! dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q 'install ok installed'; then
                missing+=("$p")
            fi
        done
        echo "Missing Debian/Ubuntu packages:"
        if [ "${#missing[@]}" -eq 0 ]; then
            echo "  (none)"
        else
            printf '  %s\n' "${missing[@]}"
            echo
            echo "  sudo apt install ${missing[*]}"
        fi
        echo "  neovim: install 0.11+ from upstream; the apt package is too old."
    else
        echo "Unknown package manager. Install manually:"
        echo "  git bash-completion fzf keychain tmux neovim(>=0.11) ripgrep fd"
        echo "  Hack font, Noto Naskh Arabic, konsole, and a C compiler"
    fi
}

link() {
    local dest="$HOME/$1" src="$DOTFILES/$2"

    if [ ! -e "$src" ]; then
        echo "Missing source: $src" >&2
        exit 1
    fi

    mkdir -p -- "$(dirname -- "$dest")"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv -v -- "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    fi
    ln -sfn -- "$src" "$dest"
    printf '  %s -> %s\n' "$dest" "$src"
}

echo "== Packages =="
print_packages

echo
echo "== Symlinks =="
link .bash_profile                 bash_profile
link .bashrc                       bashrc
link .inputrc                      inputrc
link .gitconfig                    git/gitconfig
link .config/tmux/tmux.conf        tmux/tmux.conf
link .config/nvim/init.lua         nvim/init.lua
link .config/fontconfig/fonts.conf fontconfig/fonts.conf

if [ -d "$HOME/.ssh" ]; then
    chmod 700 "$HOME/.ssh"
fi
if [ -e "$HOME/.ssh/config" ]; then
    chmod 600 "$HOME/.ssh/config"
fi

echo
echo "Left as local files (not linked): ~/.ssh/config, ~/.gitconfig-work"
echo "Copy the repo templates on a new machine, then fill in the values."
echo "Konsole files are copied too; see README.md."
