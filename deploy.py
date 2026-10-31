#!/usr/bin/env python3
"""Print the packages still missing on this machine and symlink this repo's
config files into $HOME.

Nothing is installed and no config is copied: existing files are moved to
<name>.bak.<timestamp> before the symlink is created, and the script is safe
to re-run.

~/.ssh/config and ~/.gitconfig-work are intentionally not linked. They hold
machine-specific values (key paths, work identity) and this repo is public,
so copy their templates by hand and edit the local copies.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path

DOTFILES = Path(__file__).resolve().parent
HOME = Path.home()

PACKAGES_ARCH = [
    "git", "base-devel", "bash-completion", "fzf", "keychain", "tmux",
    "neovim", "ripgrep", "fd", "noto-fonts", "ttf-hack", "konsole",
]
PACKAGES_DEBIAN = [
    "git", "build-essential", "bash-completion", "fzf", "keychain", "tmux",
    "ripgrep", "fd-find", "fonts-noto-core", "fonts-hack", "fontconfig",
    "konsole",
]

# (destination relative to $HOME, source relative to this repo)
LINKS = [
    (".bash_profile", "bash_profile"),
    (".bashrc", "bashrc"),
    (".inputrc", "inputrc"),
    (".gitconfig", "git/gitconfig"),
    (".config/tmux/tmux.conf", "tmux/tmux.conf"),
    (".config/nvim/init.lua", "nvim/init.lua"),
    (".config/fontconfig/fonts.conf", "fontconfig/fonts.conf"),
]


def run(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(args, capture_output=True, text=True)


def pacman_has(package: str) -> bool:
    return run("pacman", "-Qq", package).returncode == 0


def apt_has(package: str) -> bool:
    result = run("dpkg-query", "-W", "-f=${Status}", package)
    return result.returncode == 0 and "install ok installed" in result.stdout


def missing_arch() -> list[str]:
    missing = []
    for package in PACKAGES_ARCH:
        if package == "base-devel":
            if not (shutil.which("gcc") and shutil.which("make")):
                missing.append(package)
        elif not pacman_has(package):
            missing.append(package)
    return missing


def missing_debian() -> list[str]:
    return [p for p in PACKAGES_DEBIAN if not apt_has(p)]


def print_packages() -> None:
    if shutil.which("pacman"):
        missing = missing_arch()
        print("Missing Arch packages:")
        if missing:
            print("  " + " ".join(missing))
            print(f"\n  sudo pacman -S --needed {' '.join(missing)}")
        else:
            print("  (none)")
    elif shutil.which("apt-get"):
        missing = missing_debian()
        print("Missing Debian/Ubuntu packages:")
        if missing:
            print("  " + " ".join(missing))
            print(f"\n  sudo apt install {' '.join(missing)}")
        else:
            print("  (none)")
        print("  neovim: install 0.11+ from upstream; the apt package is too old.")
    else:
        print("Unknown package manager. Install manually:")
        print("  git bash-completion fzf keychain tmux neovim(>=0.11) ripgrep fd")
        print("  Hack font, Noto Naskh Arabic, konsole, and a C compiler")


def backup(path: Path) -> None:
    """Move an existing regular file out of the way (not a symlink)."""
    if path.is_symlink() or not path.exists():
        return
    stamp = datetime.now().strftime("%Y%m%d%H%M%S")
    target = path.with_name(f"{path.name}.bak.{stamp}")
    print(f"  backup {path} -> {target}")
    path.rename(target)


def link(dest_rel: str, src_rel: str) -> None:
    dest = HOME / dest_rel
    src = DOTFILES / src_rel

    if not src.exists():
        sys.exit(f"Missing source: {src}")

    dest.parent.mkdir(parents=True, exist_ok=True)
    backup(dest)
    dest.unlink(missing_ok=True)
    dest.symlink_to(src)
    print(f"  {dest} -> {src}")


def main() -> None:
    print("== Packages ==")
    print_packages()

    print("\n== Symlinks ==")
    for dest, src in LINKS:
        link(dest, src)

    ssh_dir = HOME / ".ssh"
    ssh_config = ssh_dir / "config"
    if ssh_dir.is_dir():
        os.chmod(ssh_dir, 0o700)
    if ssh_config.exists():
        os.chmod(ssh_config, 0o600)

    print("\nLeft as local files (not linked): ~/.ssh/config, ~/.gitconfig-work")
    print("Copy the repo templates on a new machine, then fill in the values.")
    print("Konsole files are copied too; see README.md.")


if __name__ == "__main__":
    main()
