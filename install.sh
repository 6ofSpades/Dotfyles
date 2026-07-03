#!/bin/bash

INSTALL_MODE=""
NONINTERACTIVE=false

case "$1" in
--link)
  INSTALL_MODE="link"
  NONINTERACTIVE=true
  ;;
--copy)
  INSTALL_MODE="copy"
  NONINTERACTIVE=true
  ;;
esac

# Check if gum is installed
if ! command -v gum &>/dev/null; then
  echo "We not see gum installed. We sad ;("
  echo "Please install gum before someone gets hurt"
  exit 1
fi

if ! command -v yay &>/dev/null; then
  echo "yay is not installed."
  echo "You should really install yay >.<"
  exit 1
fi

# validate sudo early cause we're gonna need it through the script
if ! $NONINTERACTIVE; then
  sudo -v
fi

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

backup() {
  BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$BACKUP_DIR"

  for item in "$DOTFILES_DIR/.config/"*; do
    name="$(basename "$item")"
    target="$HOME/.config/$name"

    if [[ -e "$target" ]]; then
      echo "Backing up $name"
      cp -a "$target" "$BACKUP_DIR/"
    fi
  done

  for item in "$DOTFILES_DIR/.local/"*; do
    name="$(basename "$item")"
    target="$HOME/.local/$name"

    if [[ -e "$target" ]]; then
      echo "Backing up $name"
      cp -a "$target" "$BACKUP_DIR/"
    fi
  done

  target="$HOME/.zshrc"

  if [[ -e "$target" ]]; then
    echo "Backing up .zshrc"
    cp -a "$target" "$BACKUP_DIR/"
  fi

  target="$HOME/.p10k.zsh"
  if [[ -e "$target" ]]; then
    echo "Backing up .p10k.zsh"
    cp -a "$target" "$BACKUP_DIR/"
  fi

  sleep 1
}

export -f backup # need these exports to make gum spin work with functions
export DOTFILES_DIR
gum spin -s line --show-error --title "Making backup..." -- bash -c backup
echo "Backup done B)"

# choose between modes
if ! $NONINTERACTIVE; then
  INSTALL_MODE=$(gum choose \
    --header "Choose installation mode:" \
    --label-delimiter "=" \
    "Symlink=link" \
    "Copy=copy")
fi

# begin installing
install_item() {
  local source="$1"
  local target="$2"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -rf -- "$target"
  fi

  if [[ "$INSTALL_MODE" == "link" ]]; then
    ln -s "$source" "$target"
    echo "Linked $(basename "$target")"
  else
    cp -a "$source" "$target"
    echo "Copied $(basename "$target")"
  fi
}

# .config folder
mkdir -p "$HOME/.config"
for item in "$DOTFILES_DIR/.config/"*; do
  name="$(basename "$item")"
  install_item "$item" "$HOME/.config/$name"
done

# .local
mkdir -p "$HOME/.local"
for item in "$DOTFILES_DIR/.local/"*; do
  name="$(basename "$item")"
  install_item "$item" "$HOME/.local/$name"
done

# top level dotfiles
for item in "$DOTFILES_DIR"/.*; do
  name="$(basename "$item")"

  case "$name" in
  . | .. | .git | .gitignore | .config | .local | scripts | install.sh)
    continue
    ;;
  esac

  install_item "$item" "$HOME/$name"
done

#### install packages
OPTIONAL_PKGS="
hyprland
hyprcursor
hypridle
hyprlock
hyprpicker
hyprsunset
qt5-wayland
qt6-wayland
kitty
xdg-desktop-portal
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
xdg-desktop-portal-termfilechooser-hunkyburrito-git
polkit
hyprpolkitagent
swww
rofi
rofi-qalc-git
rofimoji-git
rofi-rbw
dunst
wlogout
waybar
wvkbd-git
wl-kbptr
wl-ime-type
wtype
ydotool
candy-icons-git
neo-candy-icons
kvantum
breeze
breeze-gtk
qt6ct-kde
nwg-look
zsh
zsh-completions
zsh-autosuggestions
zsh-syntax-highlighting
zsh-vi-mode
starship
wiremix
cava
genact
bat
btop
fastfetch
lolcat
figlet
yazi
tray-tui
neo-matrix
terminaltexteffects-git
noto-fonts
noto-fonts-emoji
ttf-jetbrains-mono-nerd
grim
flameshot
clipvault
wl-clipboard
mpv
resvg
poppler
ffmpeg
imagemagick
autotrash
"
# Prompt selection
if ! $NONINTERACTIVE; then
  SELECTED=$(echo "$OPTIONAL_PKGS" | gum choose \
    --selected "*" \
    --no-limit \
    --header "
    Select the packages you want installed.
    Everything is selected by default.
    What's already installed will be auto skipped.
      ")
else
  SELECTED="$OPTIONAL_PKGS"
fi

# Convert to sanitized array
mapfile -t OPTIONAL_PKGS < <(
  printf '%s\n' "$SELECTED" |
    grep -vE '^[[:space:]]*(#|$)'
)

if ((${#OPTIONAL_PKGS[@]} > 0)); then
  echo "Installing the things you selected..."
  yay -S --needed "${OPTIONAL_PKGS[@]}" --makepkgconf="$HOME/.config/pacman/makepkg.conf" --config="$HOME/.config/pacman/pacman.conf" --devel --cleanafter --save
else
  echo "Nothing to install."
  echo "We'll still run yay just to save to the config file."
  yay --makepkgconf="$HOME/.config/pacman/makepkg.conf" --config="$HOME/.config/pacman/pacman.conf" --devel --cleanafter --save
fi

gum confirm --default "Install and enable ydotool service?" && ydot_serv="y" || ydot_serv="n"
if [[ "$ydot_serv" == "y" ]]; then
  USER_UID=$(id -u)

  sudo bash -c "cat > /etc/systemd/system/ydotoold.service << EOF
  [Unit]
  Description=Ydotool Daemon
  After=user@$USER_UID.service
  Requires=user@$USER_UID.service
  BindsTo=user@$USER_UID.service

  [Service]
  Type=simple
  ExecStart=/usr/bin/ydotoold \
    --socket-path=/run/user/$USER_UID/.ydotool_socket \
    --socket-own=$USER_UID:$USER_UID
  Restart=always
  RestartSec=1s

  [Install]
  WantedBy=user@$USER_UID.service
EOF"

  sudo systemctl enable ydotoold

  echo "ydotool service enabled."
fi

gum confirm --default "Run additional config and theme scripts?" && scripts="y" || scripts="n"
if [[ "$scripts" == "y" ]]; then
  # if flameshot was installed, auto configure the save path
  if [[ $(yay -Qs flameshot) ]]; then
    mkdir -p "$HOME/Pictures/flameshot"
    sed -i "s/user/$USER/g" "$HOME/.config/flameshot/flameshot.ini"
  fi

  if [[ $(yay -Qs candy-icons) ]]; then
    cd "$DOTFILES_DIR/scripts/theme-fixes/candy-icons"
    ./fix
  fi
  if [[ $(yay -Qs pear-desktop) ]]; then
    cd "$DOTFILES_DIR/scripts/theme-fixes/pear-desktop"
    ./patch
  fi
  if [[ $(yay -Qs proton-vpn) ]]; then
    cd "$DOTFILES_DIR/scripts/theme-fixes/protonvpn-trayicon"
    ./patch
  fi
  if [[ $(yay -Qs signal-desktop) ]]; then
    cd "$DOTFILES_DIR/scripts/theme-fixes/signal-themer"
    ./patch.sh
  fi

  cd
fi

gum style "Dotfyles installed." --foreground "#00ff00" --bold --padding "1 1"
