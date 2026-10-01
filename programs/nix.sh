#!/usr/bin/env -S bash -e

# this script installs all programs globally listed down below via Nix

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

PROGRAMS=(
    datasette
    sqlite-utils
    localsend
    postman
    mp3gain
    lowfi
    resonance
    keypunch
    appflowy
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

# Install the programs into the user's Nix profile
info_print "Installing programs"

nix profile install "${PROGRAMS[@]/#/nixpkgs#}"
