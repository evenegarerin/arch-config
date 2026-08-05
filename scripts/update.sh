#!/usr/bin/env bash

if [ "$EUID" -eq 0 ]; then
  echo "Please run this script as a normal user, not with sudo."
  echo "The script will ask for sudo when needed."
  exit 1
fi

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# installing programs as specified by the programs directory

PROGRAMS_DIR="$(cd "$SCRIPT_DIR/../programs" && pwd)"

# Read a program list file: strip comments (incl. trailing "# ..."), trim, drop blanks.
read_list() {
  local file="$1"
  [ -f "$file" ] || return 0
  sed -e 's/#.*$//' -e 's/[[:space:]]*$//' -e 's/^[[:space:]]*//' "$file" \
    | grep -v '^$' || true
}

###############################################################################
# pacman (official repos)
###############################################################################

sudo pacman -Syu

install_pacman() {
  echo "==> pacman packages"
  local want missing=()
  mapfile -t want < <(read_list "$PROGRAMS_DIR/pacman.txt")
  for p in "${want[@]}"; do
    if ! pacman -Qq "$p" &>/dev/null; then
      missing+=("$p")
    fi
  done
  if [ "${#missing[@]}" -eq 0 ]; then
    echo "    nothing to install"
  else
    echo "    installing: ${missing[*]}"
    sudo pacman -S --needed --noconfirm "${missing[@]}"
  fi
}

###############################################################################
# AUR (yay)
###############################################################################
# Bootstrap the yay AUR helper if it is missing (needs base-devel + git,
# which setup.sh installs). Runs as the normal user with a real network.
bootstrap_yay() {
  command -v yay &>/dev/null && return 0
  echo "    yay not found - bootstrapping from AUR"
  local tmp
  tmp="$(mktemp -d)"
  git clone https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  ( cd "$tmp/yay-bin" && makepkg -si --noconfirm )
  rm -rf "$tmp"
}

install_aur() {
  echo "==> AUR packages"
  bootstrap_yay
  if ! command -v yay &>/dev/null; then
    echo "    !! yay still not available. Skipping AUR packages."
    return
  fi
  local want missing=()
  mapfile -t want < <(read_list "$PROGRAMS_DIR/aur.txt")
  for p in "${want[@]}"; do
    if ! pacman -Qq "$p" &>/dev/null; then
      missing+=("$p")
    fi
  done
  if [ "${#missing[@]}" -eq 0 ]; then
    echo "    nothing to install"
  else
    echo "    installing: ${missing[*]}"
    yay -S --needed --noconfirm "${missing[@]}"
  fi
}

###############################################################################
# npm (global)
###############################################################################
install_npm() {
  echo "==> global npm packages"
  if ! command -v npm &>/dev/null; then
    echo "    !! npm not found (install nodejs/npm via pacman first). Skipping."
    return
  fi
  local want installed
  mapfile -t want < <(read_list "$PROGRAMS_DIR/npm.txt")
  installed="$(npm ls -g --depth=0 --parseable 2>/dev/null || true)"
  for p in "${want[@]}"; do
    # strip any version range, keep the package name (incl. @scope/name)
    local name="$p"
    if echo "$installed" | grep -q "/node_modules/${name}$"; then
      echo "    = already installed: $name"
    else
      echo "    installing: $name"
      sudo npm install -g "$name"
    fi
  done
}

###############################################################################
# VSCodium extensions
###############################################################################
install_vscode() {
  echo "==> VSCodium extensions"
  if ! command -v codium &>/dev/null; then
    echo "    !! codium not found (install vscodium-bin via AUR first). Skipping."
    return
  fi
  local want installed
  mapfile -t want < <(read_list "$PROGRAMS_DIR/vscode.txt")
  installed="$(codium --list-extensions 2>/dev/null || true)"
  for ext in "${want[@]}"; do
    if echo "$installed" | grep -qix "$ext"; then
      echo "    = already installed: $ext"
    else
      echo "    installing: $ext"
      codium --install-extension "$ext" || echo "    !! failed: $ext"
    fi
  done
}

install_pacman
install_aur
install_npm
install_vscode


# # configure programs based on ../config

# CONFIG_DIR="$(cd "$SCRIPT_DIR/../config" && pwd)"

# links=(
#   "hypr|$HOME/.config/hypr"
#   "waybar|$HOME/.config/waybar"
#   "wofi|$HOME/.config/wofi"
#   "kitty|$HOME/.config/kitty"
#   "nvim|$HOME/.config/nvim"
#   "qutebrowser|$HOME/.config/qutebrowser"
#   "swaync|$HOME/.config/swaync"
#   "yazi|$HOME/.config/yazi"
#   "gtk-3.0|$HOME/.config/gtk-3.0"
#   "gtk-4.0|$HOME/.config/gtk-4.0"
#   "wallpapers|$HOME/.config/wallpapers"
#   "cheatsheets|$HOME/.config/cheatsheets"
#   "zsh/.zshrc|$HOME/.zshrc"
#   "vscodium/settings.json|$HOME/.config/VSCodium/User/settings.json"
# )

# link_one() {
#   local src="$CONFIG_DIR/$1"
#   local dst="$2"

#   if [ ! -e "$src" ]; then
#     echo "  ! skip (missing source): $src"
#     return
#   fi

#   # already the correct symlink?
#   if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
#     echo "  = ok: $dst"
#     return
#   fi

#   mkdir -p "$(dirname "$dst")"

#   # back up anything already there
#   if [ -e "$dst" ] || [ -L "$dst" ]; then
#     echo "  ~ backup: $dst -> $dst.bak.$STAMP"
#     mv "$dst" "$dst.bak.$STAMP"
#   fi

#   ln -s "$src" "$dst"
#   echo "  + link: $dst -> $src"
# }

# echo "Linking config from $CONFIG_DIR ..."
# for entry in "${links[@]}"; do
#   link_one "${entry%%|*}" "${entry##*|}"
# done

# # make sure the helper scripts referenced by the configs are executable
# chmod +x "$CONFIG_DIR"/wofi/wofi-into-empty-workspace.sh "$CONFIG_DIR"/hypr/code.sh 2>/dev/null || true

# # firefox enterprise policy (homepage, bookmarks, force-installed extensions,
# # language packs - from firefox.nix). Lives under /etc, so it needs root.
# ff_policy_src="$CONFIG_DIR/firefox/policies.json"
# ff_policy_dst="/etc/firefox/policies/policies.json"
# if [ -f "$ff_policy_src" ]; then
#   echo "Installing firefox policy to $ff_policy_dst (needs sudo)"
#   if sudo mkdir -p /etc/firefox/policies; then
#     sudo ln -sfn "$ff_policy_src" "$ff_policy_dst" \
#       && echo "  + link: $ff_policy_dst -> $ff_policy_src" \
#       || echo "  !! failed to link firefox policy"
#   fi
# fi

# # screenshot directory used by hyprshot (HYPRSHOT_DIR in hyprland.conf)
# mkdir -p "$HOME/Pictures/Screenshots"

# # default vscode workspaces (from vscode.nix home.activation.createWorkspaces)
# ws_dir="$HOME/.vscode-workspaces"
# mkdir -p "$ws_dir"
# for name in default nix-config elm react python; do
#   f="$ws_dir/$name.code-workspace"
#   [ -f "$f" ] || echo '{ "folders": [] }' > "$f"
# done

# echo "Done."
