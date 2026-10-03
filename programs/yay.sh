#!/usr/bin/env -S bash -e

# this script installs all programs listed down below from the aur via yay

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

PROGRAMS=(
    python-lsp-ruff
    localsend-bin
    appflowy-bin
    opencode-bin
    openchamber-desktop-appimage
)

info_print "Installing programs globally via npm"

# keeping the system up to date
if ! command -v yay >/dev/null 2>&1; then
    info_print "Installing yay"

    pacman -Syuq --noconfirm

    if ! command -v git >/dev/null 2>&1; then
        pacman -Sq --needed --noconfirm git
    fi

    temp_dir=$(mktemp -d)
    chown "$SUDO_USER:$SUDO_USER" "$temp_dir"

    cd "$temp_dir"

    runuser -u "$SUDO_USER" -- git clone https://aur.archlinux.org/yay.git .
    
    runuser -u "$SUDO_USER" -- makepkg -sic --noconfirm
    
    cd ..
    rm -rf "$temp_dir"
fi

# Install all programs in a single transaction
info_print "Installing programs"

runuser -u "$SUDO_USER" -- yay -Sq --noconfirm "${PROGRAMS[@]}"