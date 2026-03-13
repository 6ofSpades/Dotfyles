# ___       _ _   _       _               _               _   
#|_ _|_ __ (_) |_(_) __ _| |   ___  _   _| |_ _ __  _   _| |_ 
# | || '_ \| | __| |/ _` | |  / _ \| | | | __| '_ \| | | | __|
# | || | | | | |_| | (_| | | | (_) | |_| | |_| |_) | |_| | |_ 
#|___|_| |_|_|\__|_|\__,_|_|  \___/ \__,_|\__| .__/ \__,_|\__|
#                                            |_|              
# Initial output
fastfetch -s none | lolcat --force -F 0.1 -S 21 -p 20| fastfetch --raw - --logo-width 38 --logo-height 20
# ---

# ____  _  ___  _  __
#|  _ \/ |/ _ \| |/ /
#| |_) | | | | | ' / 
#|  __/| | |_| | . \ 
#|_|   |_|\___/|_|\_\
# P10K
## Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
#
# source ~/.config/powerlevel10k/powerlevel10k.zsh-theme
#
# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# ---
#

#  ____      _                
# / ___|___ | | ___  _ __ ___ 
#| |   / _ \| |/ _ \| '__/ __|
#| |__| (_) | | (_) | |  \__ \
# \____\___/|_|\___/|_|  |___/
# Colors
## This will set the default prompt to chosen theme
# Good if you don't wanna use p10k or starship
#prompt fire "#2d0861" "#55007c" "#6f00a2" white white magenta

# ls colors
# 35 will make directories purple instead of blue, etc.
LS_COLORS=$LS_COLORS:'di=1;34:' ; export LS_COLORS

#---


#  ____             __ _       
# / ___|___  _ __  / _(_) __ _ 
#| |   / _ \| '_ \| |_| |/ _` |
#| |__| (_) | | | |  _| | (_| |
# \____\___/|_| |_|_| |_|\__, |
#                        |___/ 
# Config
# History and auto-generated config
HISTFILE=~/.zsh_histfile
HISTSIZE=100000 # number of lines of history kept in memory
SAVEHIST=100000 # number of lines of history saved to the histfile
setopt EXTENDED_HISTORY # Make the history actually work

# Simple config
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # dont care about capitalization for completion

typeset -U path PATH
path=(~/.local/bin $path)
export PATH

# Make neovim the default editor
export EDITOR=nvim
export SYSTEMD_EDITOR=nvim

zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
# ---

#  _  __          _     _           _     
#| |/ /___ _   _| |__ (_)_ __   __| |___ 
#| ' // _ \ | | | '_ \| | '_ \ / _` / __|
#| . \  __/ |_| | |_) | | | | | (_| \__ \
#|_|\_\___|\__, |_.__/|_|_| |_|\__,_|___/
#          |___/                         
# Keybinds
#
# vi mode or emacs mode
bindkey -v
# The delay of pressing Esc key in vi mode is 0.4s by default, and
# you can make it shorter (0.01s) with
export KEYTIMEOUT=1

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# Yank to the system clipboard
# function vi-yank-xclip {
#     zle vi-yank
#    echo "$CUTBUFFER" | wl-copy
# }
#
# zle -N vi-yank-xclip
# bindkey -M vicmd 'y' vi-yank-xclip
# ---

#    _    _ _           
#   / \  | (_) __ _ ___ 
#  / _ \ | | |/ _` / __|
# / ___ \| | | (_| \__ \
#/_/   \_\_|_|\__,_|___/
# Alias
alias yayu='arch-update'

alias journalctl='journalctl -S yesterday' # filter since yesterday by defautl

alias history='history -i'  # add timestamp to history
# fh - fzf command history
fh() {
  print -z $(
    ([ -n "$ZSH_NAME" ] && fc -li 1 || history) |
    fzf +s --tac |
    sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+[0-9-]+[[:space:]]+[0-9:]+[[:space:]]+//' |
    sed -E 's/\\/\\\\/g'
  )
}

alias hy='start-hyprland' ## To start Hyprland from the TTY easily
alias hyconf='cd ~/.config/hypr && nvim' ## Just cause I need to access config all the time

alias ip='ip -color'
alias ls='ls --color'
alias grep='grep --color=auto'

alias pubip='curl https://ipinfo.io/ip' # useful to get your public ip from the terminal

alias cat='bat'
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain --paging=never'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain --paging=never'

alias takesnap='sudo snapper -c root create -c number --description'  # For manually taking snapshots easily. Have to put description
# ---

# __   __        _ 
# \ \ / /_ _ ___(_)
#  \ V / _` |_  / |
#   | | (_| |/ /| |
#   |_|\__,_/___|_|
# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
# ---

# ____  _             _           
#|  _ \| |_   _  __ _(_)_ __  ___ 
#| |_) | | | | |/ _` | | '_ \/ __|
#|  __/| | |_| | (_| | | | | \__ \
#|_|   |_|\__,_|\__, |_|_| |_|___/
#               |___/             
# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

## Syntax highlighting color tweaking
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue,underline
ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue,underline
ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue

## zsh-vi-mode plugin config
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_HIGHLIGHT_BACKGROUND=#690086

# zsh-vi-mode key overrides
function zvm_after_lazy_keybindings() {
  # Paste with p instead of gp
  zvm_bindkey vicmd 'p' zvm_paste_clipboard_after
  zvm_bindkey vicmd 'P' zvm_paste_clipboard_before
  zvm_bindkey visual 'p' zvm_visual_paste_clipboard
  zvm_bindkey visual 'P' zvm_visual_paste_clipboard
}

## Zoxide
eval "$(zoxide init zsh)"

## Starship
eval "$(starship init zsh)"
