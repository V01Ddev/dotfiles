# dotfiles

Personal Linux workstation configuration for bash/readline, git, SSH, tmux,
Neovim, Konsole and fontconfig.

Config files are **symlinked** into place rather than copied, so the repo stays
the single source of truth: `git pull` updates the live setup, and local edits
show up in `git status`. Two kinds of files are exceptions: the Konsole files
are copied because Konsole rewrites them from its UI, and `~/.ssh/config` and
`~/.gitconfig-work` stay local because they hold machine-specific values and
this repo is public.

The deploy script handles Arch Linux and Debian/Ubuntu.

## Deployment map

| Repo path | Destination | How |
| --- | --- | --- |
| `bash_profile` | `~/.bash_profile` | symlink |
| `bashrc` | `~/.bashrc` | symlink |
| `inputrc` | `~/.inputrc` | symlink |
| `git/gitconfig` | `~/.gitconfig` | symlink |
| `git/gitconfig-work` | `~/.gitconfig-work` | local template |
| `ssh/config` | `~/.ssh/config` | local template |
| `tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | symlink |
| `nvim/init.lua` | `~/.config/nvim/init.lua` | symlink |
| `fontconfig/fonts.conf` | `~/.config/fontconfig/fonts.conf` | symlink |
| `konsole/*` | `~/.local/share/konsole/` | copy |

## 1. Clone the repo

```bash
git clone https://github.com/V01Ddev/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Any path works; `deploy.sh` resolves the repo from its own location. The manual
`cp` examples below assume `~/dotfiles`.


## 2. Run the deploy script


```bash
./deploy.sh
```

It does two things:

1. Prints the packages still missing on this machine, with the install command
   for `pacman` or `apt`. It never installs anything.
2. Symlinks the config files from the map into place. Existing files are moved
   to `<name>.bak.<timestamp>` first, and the script is safe to re-run.

It does not touch `~/.ssh/config` or `~/.gitconfig-work`; copy and edit those
by hand as described in
[the machine-specific steps](#4-fill-in-the-machine-specific-parts). The
Konsole files are copied in the next step.

The Neovim link targets the `init.lua` **file**, not the whole `nvim/`
directory, so `lazy-lock.json` and spell files stay in `~/.config/nvim`. On
tmux older than 3.2, link it to `~/.tmux.conf` instead of
`~/.config/tmux/tmux.conf`.

### Package notes

- `neovim` — must be **0.11+**; the config uses `vim.lsp.config` and the
  `main` branch of nvim-treesitter. Debian/Ubuntu repository packages are
  usually too old, so install the upstream release (AppImage or tarball).
- `base-devel` / `build-essential` — C compiler needed to build tree-sitter
  parsers.
- `fzf` — must be **0.48+** because `bashrc` uses `fzf --bash`. On older
  versions, source `/usr/share/fzf/key-bindings.bash` and
  `/usr/share/fzf/completion.bash` instead.
- `ripgrep` — Telescope's live grep. `fd` — Telescope's file finder. Debian
  ships the binary as `fdfind`; create the expected name:
  `mkdir -p ~/.local/bin && ln -s "$(command -v fdfind)" ~/.local/bin/fd`
  (`~/.local/bin` is already on `PATH` in `bashrc`).
- `ttf-hack` / `fonts-hack` — the font used by the Konsole profile.
- `noto-fonts` / `fonts-noto-core` — Noto Naskh Arabic, used for Arabic text
  in `fonts.conf`.
- `keychain` — optional; `bash_profile` uses it only if it is installed.
- `texlive` + `latexmk` — optional, for the VimTeX Neovim plugin.

## 3. Copy the Konsole files

```bash
mkdir -p ~/.local/share/konsole
cp ~/dotfiles/konsole/rose-pine.colorscheme \
   ~/dotfiles/konsole/"Profile 1.profile" \
   ~/.local/share/konsole/
```

Then in Konsole: **Settings → Configure Konsole → Profiles → Profile 1 →
Appearance → rose-pine**. The scheme uses transparency and blur, which require
a compositor (KWin handles both). tmux's status colors use the terminal's ANSI
palette, so the rose-pine look depends on this Konsole scheme.

## 4. Fill in the machine-specific parts

`~/.ssh/config` and `~/.gitconfig-work` are the two local templates: they are
not symlinked, so edits stay on this machine and are never committed.

### SSH keys

`ssh/config` contains `{path/to/private_key}` placeholders for the
`github.com`, `devops` (Azure) and `aj` hosts. Copy the template and generate
the keys:

```bash
cp ~/dotfiles/ssh/config ~/.ssh/config
chmod 600 ~/.ssh/config
ssh-keygen -t ed25519 -C "personal" -f ~/.ssh/git
ssh-keygen -t ed25519 -C "work" -f ~/.ssh/work_github
```

Add `~/.ssh/git.pub` and `~/.ssh/work_github.pub` to the matching accounts,
then replace each placeholder with the real key path (for example
`~/.ssh/git`). The two names above are what `bash_profile` loads through
keychain; if you use different names, update that line too.

### Git identity

`~/.gitconfig` sets the personal identity and uses
`includeIf "gitdir:~/Work/"` to load `~/.gitconfig-work` for repos under
`~/Work/`. The repo copy is blank on purpose (the repo is public); create the
local file and fill it in:

```bash
cp ~/dotfiles/git/gitconfig-work ~/.gitconfig-work
```

Adjust the include path if work repos live elsewhere.

### Claude Code via DeepSeek (optional)

`bash_profile` points Claude Code at DeepSeek and sources an optional token
file. The file holds exactly one line:

```bash
printf 'export ANTHROPIC_AUTH_TOKEN="%s"\n' "YOUR_TOKEN" > ~/.anthropic-token
chmod 600 ~/.anthropic-token
```

If you do not use that setup, delete or ignore that block — the variables only
affect Claude Code.

### TeX Live

`bash_profile` puts `/usr/local/texlive/2025/bin` (and the matching man/info
paths) on `PATH`. Change the year or remove those exports if you install TeX
Live elsewhere or not at all.

### Login shell caveat

The environment exports (PATH, keychain, DeepSeek) live in `~/.bash_profile`,
which bash only reads for **login** shells. If your terminal emulator starts a
non-login shell, those variables will be missing in new terminals — enable
"Start as login shell" in the terminal profile. `~/.bashrc` is always read by
interactive shells.

### Keyboard repeat (optional, manual)

Per `key.md`: delay **400 ms**, rate **40 repeats/s** (Desktop Environment →
Keyboard).

## 5. First Neovim start

```bash
nvim
```

The first launch needs network access. lazy.nvim bootstraps itself and installs
the plugins; nvim-treesitter compiles the baseline parsers; Mason installs the
LSP servers listed in `init.lua` into `~/.local/share/nvim`. This takes a few
minutes. Run `:checkhealth` afterwards.

Mason installs the language *servers*, not the toolchains — install Python,
PHP, Node, Go, Clang, etc. as needed for real completion and diagnostics.

## 6. Verify

Open a fresh terminal (or run `exec bash -l` first), then:

```bash
tmux -V                       # 3.2+ for the XDG config path
nvim --version | head -n1     # must be 0.11+
fzf --version                 # must be 0.48+
git config --get user.email   # personal identity
fc-match "Noto Naskh Arabic"  # should print the Arabic font
```

## Updating

```bash
cd ~/dotfiles && git pull
```

- bash: open a new terminal, or run `exec bash -l`.
- tmux: reload a running server with
  `tmux source-file ~/.config/tmux/tmux.conf`.
- Neovim: restart it; `:Lazy sync` updates plugins.
- Konsole, `~/.ssh/config` and `~/.gitconfig-work`: copies, not symlinks —
  re-copy if their repo templates change.

## Not part of the deployment

`scripts/`, `terminator/`, `esp32/`, `latex/`, `easyeffect/`, `basic_docs/`,
`restic.md`, `Dockerfile` and the keyboard JSON are project files, notes and
templates kept in the same repo — they are not workstation config.
