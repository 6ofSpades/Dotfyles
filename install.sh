#!/usr/bin/env bash
# Arch Linux dotfiles installer. Run --help for unattended and selective installs.
# Explicit status checks are intentional: optional steps run inside conditionals,
# where Bash's errexit would not reliably stop a failing function.

INSTALL_MODE=""
NONINTERACTIVE=false
SKIP_PACKAGES=false
SKIP_PROJECTS=false
SKIP_EXTRAS=false
ENABLE_YDOTOOL=false
BACKUP_DIR=""
WORK_DIR=""
SKIPPED_STEPS=()
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

usage() {
  cat <<'HELP'
Usage: ./install.sh [--link | --copy] [options]

Without a mode, ask whether to symlink or copy the dotfiles.
  --link             Symlink dotfiles; run without prompts
  --copy             Copy dotfiles; run without prompts
  --interactive      Keep prompts even when a mode is supplied
  --skip-packages    Skip system upgrade and optional package installation
  --skip-projects    Skip pytab, pyhist, Flowkeep and theemr setup
  --skip-extras      Skip personalized paths and WayVNC key generation
  --enable-ydotool   Install and enable the system ydotool service
  -h, --help         Show this help

Noninteractive runs stop on errors. Interactive runs can skip failed optional
steps. Existing project clones are reused without pulling or resetting them.
Theemr's private repository requires working GitHub authentication.
Personalized config directories and .local/bin stay real directories even in
link mode, so generated files do not get written into the source repository.
HELP
}

error() { printf 'ERROR: %s\n' "$*" >&2; }

parse_args() {
  local arg interactive=false
  for arg in "$@"; do
    case "$arg" in
      --link | --copy)
        if [[ -n "$INSTALL_MODE" && "$INSTALL_MODE" != "${arg#--}" ]]; then
          error 'Choose either --link or --copy.'; return 1
        fi
        INSTALL_MODE="${arg#--}"; NONINTERACTIVE=true ;;
      --interactive) interactive=true ;;
      --skip-packages) SKIP_PACKAGES=true ;;
      --skip-projects) SKIP_PROJECTS=true ;;
      --skip-extras) SKIP_EXTRAS=true ;;
      --enable-ydotool) ENABLE_YDOTOOL=true ;;
      *) error "Unknown option: $arg"; return 1 ;;
    esac
  done
  if $interactive; then NONINTERACTIVE=false; fi
}

cleanup() {
  if [[ -n "$WORK_DIR" && -d "$WORK_DIR" ]]; then
    rm -rf -- "$WORK_DIR"
  fi
}

# A failed optional step never gets disguised as a successful installation.
run_step() {
  local label="$1" action
  shift
  printf '\n%s...\n' "$label"
  if "$@"; then return 0; fi
  error "$label failed. See the error above."
  if $NONINTERACTIVE; then return 1; fi
  action=$(gum choose --header "$label failed. What next?" \
    'Stop installation' 'Skip and continue') || return 1
  [[ "$action" == 'Skip and continue' ]] || return 1
  SKIPPED_STEPS+=("$label")
  printf 'Skipping %s.\n' "$label"
}

preflight() {
  local tool directory
  for directory in "$HOME/.config" "$HOME/.local"; do
    if [[ -L "$directory" ]]; then
      error "Expected a real directory, not a symlink: $directory"; return 1
    fi
  done
  if [[ $(id -u) == 0 ]]; then
    error 'Run this as your normal user, without sudo.'; return 1
  fi
  for tool in git python3 mktemp realpath; do
    command -v "$tool" >/dev/null 2>&1 || { error "Required tool missing: $tool"; return 1; }
  done
  if ! $NONINTERACTIVE; then
    command -v gum >/dev/null 2>&1 || { error 'Please install gum first.'; return 1; }
    [[ -t 0 && -t 1 ]] || { error 'Prompts need a terminal; use --link or --copy.'; return 1; }
  fi
  if ! $SKIP_PACKAGES; then
    command -v yay >/dev/null 2>&1 || { error 'Please install yay first.'; return 1; }
    [[ -r "$DOTFILES_DIR/scripts/install/packages.txt" ]] || return 1
  fi
  if ! $SKIP_PACKAGES || $ENABLE_YDOTOOL; then
    command -v sudo >/dev/null 2>&1 || return 1
    if $NONINTERACTIVE; then
      sudo -n -v || { error 'Sudo needs authentication; run sudo -v first or use --interactive.'; return 1; }
    else
      sudo -v || return 1
    fi
  fi
}

# Stage the new item before moving the old one into a namespaced backup.
# Never follow a destination symlink when replacing it, including broken links.
install_item() {
  local source="$1" target="$2" mode="${3:-$INSTALL_MODE}" stage relative saved
  [[ -e "$source" || -L "$source" ]] || { error "Missing source: $source"; return 1; }
  if [[ -e "$target" && "$source" -ef "$target" ]]; then
    if [[ "$mode" == link || ! -L "$target" ]]; then return 0; fi
  fi
  case "$DOTFILES_DIR/" in
    "$target/"*) error "Refusing to replace the repository's parent: $target"; return 1 ;;
  esac
  mkdir -p -- "${target%/*}" || return 1
  stage=$(mktemp -d "${target%/*}/.dotfiles-install.XXXXXX") || return 1
  if [[ "$mode" == link ]]; then
    ln -s -- "$source" "$stage/item" || { rmdir -- "$stage"; return 1; }
  else
    cp -a -- "$source" "$stage/item" || { rm -rf -- "$stage"; return 1; }
  fi
  relative="${target#"$HOME/"}"
  saved=""
  if [[ -e "$target" || -L "$target" ]]; then
    saved=$(mktemp -d "$BACKUP_DIR/entry.XXXXXX") || { rm -rf -- "$stage"; return 1; }
    saved="$saved/$relative"
    if ! mkdir -p -- "${saved%/*}" || ! mv -T -- "$target" "$saved"; then
      rm -rf -- "$stage"; return 1
    fi
  fi
  if ! mv -T -- "$stage/item" "$target"; then
    if [[ -n "$saved" && ( -e "$saved" || -L "$saved" ) ]]; then
      mv -T -- "$saved" "$target" || error "Restore $target from $saved manually."
    fi
    rm -rf -- "$stage"; return 1
  fi
  rmdir -- "$stage" || return 1
  printf 'Installed %s (%s)\n' "$relative" "$mode"
}

# These directories receive local files or personalized paths after deployment.
install_local_directory() {
  local target="$1"
  if [[ -L "$target" ]]; then
    [[ -d "$target" ]] || { error "Broken directory symlink: $target"; return 1; }
    local materialized
    materialized=$(mktemp -d "$WORK_DIR/materialized.XXXXXX") || return 1
    cp -a -- "$target/." "$materialized/" || return 1
    install_item "$materialized" "$target" copy || return 1
  elif [[ ! -e "$target" ]]; then
    mkdir -p -- "$target" || return 1
  elif [[ ! -d "$target" ]]; then
    error "Expected a directory: $target"; return 1
  fi
}

install_dotfiles() {
  local source name mode
  mkdir -p -- "$HOME/.dotfiles-backups" || return 1
  BACKUP_DIR=$(mktemp -d "$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S).XXXXXX") || return 1
  printf 'Backups: %s\n' "$BACKUP_DIR"
  for source in "$DOTFILES_DIR/.config/"*; do
    name="${source##*/}"; mode="$INSTALL_MODE"
    case "$name" in
      flameshot | xdg-desktop-portal-termfilechooser | 'YouTube Music' | wayvnc)
        mode=copy
        install_local_directory "$HOME/.config/$name" || return 1
        # Merge individual files to preserve runtime files such as existing keys.
        local child
        for child in "$source/"*; do
          install_item "$child" "$HOME/.config/$name/${child##*/}" copy || return 1
        done
        continue ;;
    esac
    install_item "$source" "$HOME/.config/$name" "$mode" || return 1
  done
  for source in "$DOTFILES_DIR/.local/"*; do
    name="${source##*/}"
    if [[ "$name" == bin ]]; then
      install_local_directory "$HOME/.local/bin" || return 1
      local executable
      for executable in "$source/"*; do
        install_item "$executable" "$HOME/.local/bin/${executable##*/}" || return 1
      done
    else
      install_item "$source" "$HOME/.local/$name" || return 1
    fi
  done
  # Only install the intended top-level dotfiles, never local .aws/.codex/etc.
  for name in .gitconfig .gtkrc-2.0 .p10k.zsh .zshrc; do
    install_item "$DOTFILES_DIR/$name" "$HOME/$name" || return 1
  done
}

install_packages() {
  local pkg selected
  local -a packages=() flags=() failed=()
  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] || packages+=("$pkg")
  done < "$DOTFILES_DIR/scripts/install/packages.txt"
  if $NONINTERACTIVE; then
    flags+=(--noconfirm)
  else
    selected=$(gum choose --no-limit --selected '*' \
      --header 'Select packages to install:' "${packages[@]}") || return 1
    packages=()
    if [[ -n "$selected" ]]; then mapfile -t packages <<< "$selected"; fi
  fi
  # Abort this step if the full upgrade fails; do not proceed with package installs.
  yay -Syu "${flags[@]}" || return 1
  for pkg in "${packages[@]}"; do
    if ! yay -S --needed "$pkg" "${flags[@]}" \
      --makepkgconf="$HOME/.config/pacman/makepkg.conf" \
      --config="$HOME/.config/pacman/pacman.conf" \
      --answerclean a --devel --cleanafter; then
      failed+=("$pkg")
    fi
  done
  if ((${#failed[@]})); then
    printf 'Failed packages: %s\n' "${failed[*]}" >&2; return 1
  fi
}

ensure_clone() {
  local url="$1" destination="$2" origin root
  if [[ -e "$destination" || -L "$destination" ]]; then
    root=$(git -C "$destination" rev-parse --show-toplevel) || return 1
    [[ "$(realpath -- "$destination")" == "$(realpath -- "$root")" ]] || return 1
    origin=$(git -C "$destination" remote get-url origin) || return 1
    origin="${origin/#git@github.com:/https://github.com/}"
    if [[ "${origin%.git}" != "${url%.git}" ]]; then
      error "Unexpected origin for $destination: $origin"; return 1
    fi
    printf 'Reusing %s (no pull or reset).\n' "$destination"
    return 0
  fi
  mkdir -p -- "${destination%/*}" || return 1
  git clone -- "$url" "$destination" || return 1
}

install_browser_helper() {
  local name="$1" server="$2" repo="$WORK_DIR/$1"
  ensure_clone "https://github.com/6ofSpades/$name" "$repo" || return 1
  install_item "$repo/$name.py" "$HOME/.config/tridactyl/$name.py" copy || return 1
  install_item "$repo/$server" "$HOME/.config/tridactyl/$server" copy || return 1
}

install_python_project() {
  local name="$1" repo="$HOME/Projects/$1" wrapper="$WORK_DIR/$1-launcher"
  ensure_clone "https://github.com/6ofSpades/$name" "$repo" || return 1
  python3 -m venv "$repo/.venv" || return 1
  if [[ "$name" == flowkeep ]]; then
    "$repo/.venv/bin/python" -m pip install -e "$repo" || return 1
    [[ -x "$repo/.venv/bin/flowkeep" ]] || return 1
    cat > "$wrapper" <<'LAUNCHER' || return 1
#!/usr/bin/env bash
exec "$HOME/Projects/flowkeep/.venv/bin/flowkeep" "$@"
LAUNCHER
  else
    "$repo/.venv/bin/python" -m pip install -r "$repo/requirements.txt" || return 1
    [[ -f "$repo/generate.py" ]] || return 1
    if [[ ! -e "$HOME/.config/theemr/colors.yaml" ]]; then
      install_item "$repo/examples/colors.yaml" "$HOME/.config/theemr/colors.yaml" copy || return 1
    fi
    cat > "$wrapper" <<'LAUNCHER' || return 1
#!/usr/bin/env bash
exec "$HOME/Projects/theemr/.venv/bin/python" "$HOME/Projects/theemr/generate.py" "$@"
LAUNCHER
  fi
  chmod +x -- "$wrapper" || return 1
  install_item "$wrapper" "$HOME/.local/bin/$name" copy || return 1
}

install_ydotool() {
  local uid unit="$WORK_DIR/ydotoold.service"
  command -v ydotoold >/dev/null 2>&1 || { error 'ydotoold is not installed.'; return 1; }
  uid=$(id -u) || return 1
  cat > "$unit" <<UNIT || return 1
[Unit]
Description=Ydotool Daemon
After=user@$uid.service
Requires=user@$uid.service
BindsTo=user@$uid.service

[Service]
ExecStart=$(command -v ydotoold) --socket-path=/run/user/$uid/.ydotool_socket --socket-own=$uid:$uid
Restart=always
RestartSec=1s

[Install]
WantedBy=user@$uid.service
UNIT
  if sudo test -e /etc/systemd/system/ydotoold.service; then
    sudo cp -a /etc/systemd/system/ydotoold.service "$BACKUP_DIR/ydotoold.service" || return 1
  fi
  sudo install -m 644 -- "$unit" /etc/systemd/system/ydotoold.service || return 1
  sudo systemctl daemon-reload || return 1
  sudo systemctl enable ydotoold.service || return 1
  sudo systemctl restart ydotoold.service || return 1
}

personalize_config() {
  # Replace only the literal placeholder, using HOME (not an assumed /home/$USER).
  # os.replace also avoids editing the referent of an existing file symlink.
  python3 - "$HOME" <<'PY'
import json
import os
from pathlib import Path
import sys
import tempfile

home = Path(sys.argv[1])
for relative in (
    '.config/flameshot/flameshot.ini',
    '.config/xdg-desktop-portal-termfilechooser/config',
    '.config/YouTube Music/config.json',
):
    path = home / relative
    if not path.is_file():
        continue
    text = path.read_text()
    if relative.endswith('.json'):
        data = json.loads(text)
        def replace(value):
            if isinstance(value, str):
                return value.replace('/home/user/', str(home) + '/')
            if isinstance(value, list):
                return [replace(item) for item in value]
            if isinstance(value, dict):
                return {key: replace(item) for key, item in value.items()}
            return value
        text = json.dumps(replace(data), indent=2) + '\n'
    else:
        text = text.replace('/home/user/', str(home) + '/')
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix='.dotfiles-config.')
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(text)
        os.chmod(temporary, path.stat().st_mode & 0o777)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
(home / 'Pictures/flameshot').mkdir(parents=True, exist_ok=True)
PY
}

setup_wayvnc_key() {
  local directory="$HOME/.config/wayvnc" key="$HOME/.config/wayvnc/rsa_key.pem"
  command -v wayvnc >/dev/null 2>&1 || return 0
  if [[ -e "$key" || -L "$key" ]]; then
    printf 'Keeping the existing WayVNC key.\n'; return 0
  fi
  command -v ssh-keygen >/dev/null 2>&1 || return 1
  mkdir -p -- "$directory" || return 1
  (umask 077; ssh-keygen -m pem -f "$key" -t rsa -N '') || return 1
}

main() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" == --help || "$arg" == -h ]]; then usage; return 0; fi
  done
  parse_args "$@" || return 2
  preflight || return 1
  if [[ -z "$INSTALL_MODE" ]]; then
    INSTALL_MODE=$(gum choose --header 'Choose installation mode:' link copy) || return 1
  fi
  [[ "$INSTALL_MODE" == link || "$INSTALL_MODE" == copy ]] || return 1
  WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-install.XXXXXX") || return 1
  trap cleanup EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  shopt -s nullglob dotglob
  install_dotfiles || { error "Dotfile deployment failed. Backups: $BACKUP_DIR"; return 1; }
  if ! $SKIP_PACKAGES; then run_step 'Install packages' install_packages || return 1; fi
  if ! $SKIP_PROJECTS; then
    run_step 'Install pytab' install_browser_helper pytab browser_server.sh || return 1
    run_step 'Install pyhist' install_browser_helper pyhist history_server.sh || return 1
    run_step 'Install flowkeep' install_python_project flowkeep || return 1
    run_step 'Install theemr' install_python_project theemr || return 1
  fi
  if ! $NONINTERACTIVE && ! $ENABLE_YDOTOOL; then
    if gum confirm 'Install and enable the system ydotool service?'; then
      ENABLE_YDOTOOL=true
    else
      local status=$?
      [[ "$status" == 1 ]] || return "$status"
    fi
  fi
  if $ENABLE_YDOTOOL; then run_step 'Set up ydotool' install_ydotool || return 1; fi
  if ! $SKIP_EXTRAS; then
    run_step 'Personalize config paths' personalize_config || return 1
    run_step 'Set up WayVNC key' setup_wayvnc_key || return 1
  fi
  if ((${#SKIPPED_STEPS[@]})); then
    printf '\nDotfyles installed with skipped steps:\n'
    printf '  - %s\n' "${SKIPPED_STEPS[@]}"
  else
    printf '\nDotfyles installed. The dots have found their homes.\n'
  fi
  printf 'Backups: %s\n' "$BACKUP_DIR"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -uo pipefail
  main "$@"
fi
