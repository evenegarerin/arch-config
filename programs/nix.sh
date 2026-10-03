#!/usr/bin/env -S bash -e

# this script installs all programs globally listed down below via Nix

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

NIXPKGS="github:NixOS/nixpkgs/nixos-26.05"

PROGRAMS=(
    # datasette # broken right now
    sqlite-utils
    # localsend     # i am having problems with flutter apps installed via nix
    # appflowy      # same as localsend
    postman
    mp3gain
    lowfi
    resonance
    keypunch
    devtoolbox
    plus-jakarta-sans
    nixd
    nixpkgs-fmt
    elmPackages.elm-format
    elmPackages.elm-language-server
    elmPackages.elm
    vscodium
    andromeda-gtk-theme
    borealis-cursors
)

info_print "Installing programs via Nix"

# keeping the system up to date
if ! command -v nix >/dev/null 2>&1; then
    info_print "Installing Nix"

    pacman -Syuq --noconfirm
    
    pacman -Sq --needed --noconfirm nix
fi

if ! systemctl is-enabled --quiet nix-daemon.service; then
    systemctl enable --now nix-daemon.service
fi

# did fail for some reason on a live install, for missing permissions, even through the script is run with sudo
mkdir -p /nix/store

# Install the programs into the user's Nix profile
info_print "Installing programs"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    runuser -u "$username" -- env NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features 'nix-command flakes' profile add --impure "${PROGRAMS[@]/#/$NIXPKGS#}"
done

echo "Nix and its programs have been installed, if this is the first instance in which nix has been installed and the programs dont appear in path run this:"
echo "source /etc/profile.d/nix-daemon.sh"
echo "or reboot"