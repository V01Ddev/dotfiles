# restic cheat sheet

Encrypted, deduplicated backups of `/home/v01d` to an external drive, and the restore
path for a fresh Linux install.

Run every command as your normal user (`v01d`) — **not** root. Restic only needs root to
assign ownership it isn't allowed to assign; running unprivileged means restored files
end up owned by you, which is what we want on a new machine.

## Environment

| What | Command | Notes |
|---|---|---|
| Repo location (once per shell) | `export RESTIC_REPOSITORY=/mnt/backup_point` | Lets you drop `-r ...` from every command below. |
| Password via env var | `export RESTIC_PASSWORD='yourpassword'` | Otherwise every command prompts interactively. |
| Password via file (safer) | `export RESTIC_PASSWORD_FILE=~/.restic-pass` | `chmod 600` the file. Better than the env var, which lands in shell history. |
| Mount the external drive | `sudo mount LABEL=backup /mnt/backup_point` | The drive is labelled `backup`, so this is stable across reboots and replugs. Restic itself never needs sudo. |
| Release KDE's auto-mount first | `sudo umount /run/media/v01d/backup` | KDE grabs removable drives on plug-in and mounts them `root:root`, so you can't write to them. If the drive is already there, unmount it before mounting at `/mnt/backup_point`. |

## Setup

| Step | Command | Notes |
|---|---|---|
| Initialize the repo | `restic init` | Once, on an empty drive. Prompts you to set a password — **there is no recovery if you lose it**, so write it down somewhere that isn't this machine. |
| Sanity-check the repo | `restic cat config` | Confirms the repo is readable without touching any data. |

## Backing up

**This is the one command you run each time.** It's self-contained — the repo path is
baked in, so it works from any directory with no environment setup:

```bash
restic -r /mnt/backup_point backup /home/v01d \
  --exclude-caches \
  --exclude-file /home/v01d/.restic-excludes \
  --verbose
```

The `\` at the end of each line is safe to paste — bash joins them back into one command.
On one line it runs off the page; wrapped like this it stays readable.

**Found something else you don't want backed up?** Add it to `~/.restic-excludes`, one
pattern per line. Nothing else changes — no command to edit, no flags to remember. The
excludes file lives in your home directory, so it gets backed up and restored too.

`--exclude-caches` auto-skips any directory tagged with `CACHEDIR.TAG` (most browser and
app caches already are); the exclude file drops the rest of the regenerable junk, such as
toolchains you'd rather reinstall than carry around (`~/.arduino15`, `~/.rustup`,
`~/.cargo/registry`, `~/.npm`, `~/.gradle`, `~/.m2` are all the same category).
`--verbose` prints every file as it's processed — useful to confirm the first run is
actually moving data, but drop it for routine runs since it's very noisy.

| Variation | Command | Notes |
|---|---|---|
| Dry run first | `restic -r /mnt/backup_point backup /home/v01d -n` | Prints what it *would* back up. Good for catching an accidental include. |
| Tag a snapshot | `restic -r /mnt/backup_point backup /home/v01d --tag pre-reinstall` | Makes old snapshots findable later via `restic snapshots --tag pre-reinstall`. |

## Inspecting

| Step | Command | Notes |
|---|---|---|
| List snapshots | `restic snapshots` | Every run is its own dated snapshot — not just the latest. |
| List snapshots by tag | `restic snapshots --tag pre-reinstall` | |
| Show repo stats | `restic stats` | Size on disk vs. size of the original data (dedup ratio). |
| Browse a snapshot's file list | `restic ls latest` | Same path output as `ls`. |
| Find a file by name | `restic find '*.kdbx'` | Searches across all snapshots. |
| Show a file without restoring | `restic dump latest /home/v01d/.bashrc` | Dumps to stdout. |
| Verify the repo | `restic check` | Checks structure and metadata. Run occasionally. |
| Verify + read all data | `restic check --read-data` | Reads every pack file — slow (hours on a big repo) but it's the only way to catch bitrot. Good to run before an OS reinstall. |

## Restoring

The gotcha: restic restores the **full original path** under `--target`. A snapshot of
`/home/v01d` restored with `--target /tmp/x` lands at `/tmp/x/home/v01d/...`, not
`/tmp/x/...`. So restore straight into place, and never as root.

| Scenario | Command | Notes |
|---|---|---|
| Restore everything, same username | `sudo mount LABEL=backup /mnt/backup_point` then `restic restore latest --target /` | Run the restore as `v01d`, no sudo. Recreates `/home/v01d/...` exactly, owned by you, permissions and timestamps intact. |
| Restore a specific snapshot | `restic restore <snapshot-id> --target /` | Snapshot ID from `restic snapshots`. |
| Restore into a scratch dir first | `restic restore latest --target /tmp/restore` | Then `mv /tmp/restore/home/v01d/* /home/v01d/`. Use this when the username differs, or when you want to look before you leap. |
| Restore only certain directories | `restic restore latest --target / --include /home/v01d/Documents --include /home/v01d/Pictures` | `--include` takes a full path or a pattern; repeat the flag per path. |
| Restore only dotfiles/config | `restic restore latest --target / --include '/home/v01d/.config' --include '/home/v01d/.ssh'` | Useful on a fresh install where you want your config but not the data. |
| Restore one file | `restic restore latest --target /home/v01d --include /home/v01d/.bashrc` | Overwrites the existing file in place. |
| Restore as the current user, forcing ownership | `restic restore latest --target /` | Only works unprivileged — that's what strips the old UID and gives everything to you. |

## Browsing without restoring

| Step | Command | Notes |
|---|---|---|
| Mount all snapshots read-only | `restic mount /mnt/restic-view` | Needs `fuse`. Browse every snapshot as a normal directory tree, copy files out by hand. |
| Unmount | `fusermount -u /mnt/restic-view` | Or Ctrl-C the process. |

## Maintenance

| Step | Command | Notes |
|---|---|---|
| List keys | `restic key list` | |
| Add a password | `restic key add` | Adds an additional password to the repo (both work afterwards). |
| Remove a password | `restic key remove` | |
| Delete one snapshot | `restic forget <snapshot-id>` | Removes the snapshot; data stays until `prune`. |
| Prune retention | `restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune` | Keeps a reasonable history and reclaims the rest. Only needed if the repo grows large. |
| Reclaim space only | `restic prune` | Drops unreferenced data left by `forget`. Slow; the `--prune` flag above is usually enough. |
| Unlock after a crash | `restic unlock` | If a killed run left a stale lock. |

## Reinstall workflow (the short version)

| Step | Command |
|---|---|
| 1. Backup | `sudo mount LABEL=backup /mnt/backup_point` |
| 2. | `restic -r /mnt/backup_point backup /home/v01d --exclude-caches --exclude-file /home/v01d/.restic-excludes` |
| 3. Verify | `restic -r /mnt/backup_point check` |
| 4. Reinstall | Create the first user as `v01d` again — matching the username avoids all path-rewriting and hardcoded-path breakage later. |
| 5. Restore | `sudo mount LABEL=backup /mnt/backup_point` |
| 6. | `restic -r /mnt/backup_point restore latest --target /` |

---

Written by [v01d.dev](https://v01d.dev)
