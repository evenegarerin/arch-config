#!/usr/bin/env -S bash -e

# this script installs all programs globally listed down below via npm

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

PROGRAMS=(
    elm-land
    elm-review
)

info_print "Installing programs globally via npm"

# keeping the system up to date
if ! command -v npm >/dev/null 2>&1; then
    info_print "Installing npm"

    sudo pacman -Syuq --noconfirm

    sudo pacman -Sq --needed --noconfirm npm
fi

# the actual installing of the programs
for program in "${PROGRAMS[@]}"; do
    echo "installing $program"
    npm install -g --silent $program
done