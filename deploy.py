#!/usr/bin/env python3
"""Print the packages still missing on this machine and symlink this repo's
config files into $HOME.

Nothing is installed and no config is copied: existing files are moved to
<name>.bak.<timestamp> before the symlink is created, and the script is safe
to re-run. Use --dry-run to preview, and --clean-backups to remove the
timestamped backups.

~/.ssh/config and ~/.gitconfig-work are intentionally not linked. They hold
machine-specific values (key paths, work identity) and this repo is public,
so copy their templates by hand and edit the local copies.
"""

from __future__ import annotations

import argparse
import os
import re
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


def backup(dest: Path, dry_run: bool) -> None:
    """Move an existing regular file out of the way (not a symlink)."""
    if dest.is_symlink() or not dest.exists():
        return

    target = dest.with_name(f"{dest.name}.bak.{datetime.now():%Y%m%d%H%M%S}")
    if dry_run:
        print(f"  would backup {dest} -> {target}")
        return

    print(f"  backup {dest} -> {target}")
    dest.rename(target)


def link(dest_rel: str, src_rel: str, dry_run: bool) -> None:
    dest = HOME / dest_rel
    src = DOTFILES / src_rel

    if not src.exists():
        sys.exit(f"Missing source: {src}")

    if dry_run:
        if not dest.parent.is_dir():
            print(f"  would create {dest.parent}")
        backup(dest, dry_run=True)
        print(f"  would link {dest} -> {src}")
        return

    dest.parent.mkdir(parents=True, exist_ok=True)
    backup(dest, dry_run=False)
    dest.unlink(missing_ok=True)
    dest.symlink_to(src)
    print(f"  {dest} -> {src}")


def backups_of(dest: Path) -> list[Path]:
    """Return the <name>.bak.<14-digit timestamp> siblings of dest."""
    if not dest.parent.is_dir():
        return []

    pattern = re.compile(rf"^{re.escape(dest.name)}\.bak\.\d{{14}}$")
    return sorted(p for p in dest.parent.iterdir() if pattern.match(p.name))


def clean_backups(dry_run: bool) -> None:
    removed = 0
    for dest_rel, _ in LINKS:
        for path in backups_of(HOME / dest_rel):
            if dry_run:
                print(f"  would delete {path}")
            else:
                print(f"  delete {path}")
                path.unlink()
            removed += 1

    if not removed:
        print("  no backups found")
    elif dry_run:
        print(f"\n{removed} backup(s) would be deleted.")
    else:
        print(f"\n{removed} backup(s) deleted.")


def chmod_ssh(dry_run: bool) -> None:
    ssh_dir = HOME / ".ssh"
    ssh_config = ssh_dir / "config"

    if ssh_dir.is_dir() and (ssh_dir.stat().st_mode & 0o777) != 0o700:
        if dry_run:
            print(f"  would chmod 700 {ssh_dir}")
        else:
            os.chmod(ssh_dir, 0o700)

    if ssh_config.exists() and (ssh_config.stat().st_mode & 0o777) != 0o600:
        if dry_run:
            print(f"  would chmod 600 {ssh_config}")
        else:
            os.chmod(ssh_config, 0o600)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Report missing packages and symlink this repo's configs into $HOME."
    )
    parser.add_argument(
        "-n", "--dry-run", action="store_true",
        help="show what would change without touching anything",
    )
    parser.add_argument(
        "-c", "--clean-backups", action="store_true",
        help="delete <name>.bak.<timestamp> files and exit",
    )
    args = parser.parse_args()

    if args.dry_run:
        print("Dry run: nothing will be changed.\n")

    if args.clean_backups:
        print("== Backups ==")
        clean_backups(args.dry_run)
        return

    print("== Packages ==")
    print_packages()

    print("\n== Symlinks ==")
    for dest, src in LINKS:
        link(dest, src, args.dry_run)

    chmod_ssh(args.dry_run)

    print("\nLeft as local files (not linked): ~/.ssh/config, ~/.gitconfig-work")
    print("Copy the repo templates on a new machine, then fill in the values.")
    print("Konsole files are copied too; see README.md.")


if __name__ == "__main__":
    main()
