#!/usr/bin/env -S bash -e

# this script installs all programs listed down below from the aur via yay

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

PROGRAMS=(
    # --- Editor ---
    vscodium-bin

    # --- GUI applications ---
    localsend-bin
    postman-bin
    appflowy-bin
    devtoolbox
    keypunch-git
    resonance-bin
    lowfi-bin
    mp3gain

    # --- Theme / cursor / fonts ---
    # xcursor-borealis
    # andromeda-gtk-theme # no
    ttf-plus-jakarta-sans  # nix: plus-jakarta-sans

    # --- Dev / language servers ---
    nixd
    nixpkgs-fmt
    python-lsp-ruff
    elm-bin
    elm-format-bin
    elm-language-server

    # --- Data tooling ---
    datasette
    sqlite-utils
)

info_print "Installing programs globally via npm"

# keeping the system up to date
if ! command -v yay >/dev/null 2>&1; then
    info_print "Installing yay"

    pacman -Syuq

    if ! command -v git >/dev/null 2>&1; then
        sudo pacman -Sq --needed git
    fi

    git clone https://aur.archlinux.org/yay.git:temp-yay .
    cd temp-yay
    makepkg -si
    cd ..
    rm -rf temp-yay
fi

# the actual installing of the programs
for program in "${PROGRAMS[@]}"; do
    echo "installing $program"
    yay install -g --silent $program
done