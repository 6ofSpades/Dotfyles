# Installer maintenance

Run `./install.sh --help` for options. This installer targets Arch Linux and must
run as a normal user. The optional package list lives in `packages.txt`.

Examples:

```bash
# Interactive installation
./install.sh

# Only deploy dotfiles, without package upgrades, clones or personalization
./install.sh --link --skip-packages --skip-projects --skip-extras

# Copy dotfiles, keeping interactive choices and failure prompts
./install.sh --copy --interactive
```

`--link` and `--copy` retain their unattended behavior. Optional steps fail fast
in unattended mode; interactive mode offers Stop or Skip. Cancelling a prompt
stops installation. Skipped failures are listed in the final report.

Unattended package installation needs cached sudo credentials (`sudo -v` first).
The system ydotool service is opt-in through `--enable-ydotool`, or a prompt in
interactive mode. Package updates, optional projects, and extras can each be
skipped independently. Project clones already in `~/Projects` are checked for
the expected origin and reused without pulling, resetting, or deleting changes.
The private theemr repository needs GitHub authentication for the initial clone.

Dotfiles are staged before replacement. Existing destinations, including broken
symlinks, are moved into a unique backup under
`~/.dotfiles-backups/<timestamp>.<suffix>/entry.<suffix>/`, retaining their paths
relative to HOME. Each replacement gets a separate entry to prevent collisions
between directory backups and later file backups. If deploying an item fails,
the installer attempts to restore that item's previous destination. Earlier
successful steps remain installed; this is not a system-wide transaction.

In link mode, `.local/bin` remains a real directory containing individual links.
The configs for Flameshot, the terminal file chooser, YouTube Music and WayVNC
are copied into real directories. This keeps generated launchers, personal
paths and WayVNC keys out of the repository. Existing WayVNC keys are preserved.
Other config directories continue to use directory symlinks. The base `.config`
and `.local` directories themselves must be real directories.

Personalization uses the actual HOME path, replacing only `/home/user/`.
Top-level dotfiles are explicitly listed in `install_dotfiles`; local directories
such as `.aws`, `.agents` and `.codex` are never automatically deployed.

Run the isolated checks with:

```bash
bash -n install.sh
python3 scripts/install/test-installer.py
```

The tests use temporary homes and mock external operations. They do not install
packages, contact GitHub, change services, or run the installer on your own HOME.
