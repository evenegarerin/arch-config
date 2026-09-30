#!/usr/bin/env -S bash -e

# this script installs all programs listed down below via pacman

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

PROGRAMS=(
    # Hyprland desktop
    hyprland
    hyprlock
    hypridle
    hyprpaper
    hyprcursor
    hyprpolkitagent
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    waybar
    wofi
    swaync
    greetd
    qt5-wayland
    qt6-wayland
    wl-clipboard
    hyprshot
    hyprlauncher
    wl-clip-persist

    # polkit
    polkit
    polkit-gnome

    # Audio (pipewire, replaces pulseaudio)
    pipewire
    pipewire-alsa
    pipewire-pulse
    pipewire-jack
    wireplumber
    lib32-pipewire        # multilib (alsa.support32Bit) - needs multilib enabled
    libpulse              # provides pactl, used by the hyprland volume binds
    rtkit

    # Bluetooth
    bluez
    bluez-utils
    blueman

    # Network
    networkmanager
    network-manager-applet

    # Power management (thinkpad / tlp)
    tlp

    # Terminal, shell & CLI tools
    kitty
    zsh
    zsh-syntax-highlighting
    neovim
    git
    fzf
    ripgrep
    fd
    jq
    yazi
    file
    brightnessctl
    playerctl
    pass
    imv
    btop

    # File managers
    nemo
    pcmanfm

    # input / event inspection tools
    wev
    xorg-xev
    evtest

    # Applications
    firefox
    firefox-i18n-de        # german language pack (firefox.nix languagePacks)
    qutebrowser
    qalculate-gtk
    gnote
    gedit
    spotify-launcher
    mission-center

    # Appearance / display helpers
    nwg-displays
    nwg-look
    papirus-icon-theme
    ttf-jetbrains-mono-nerd

    # Development
    nodejs
    npm
    pnpm
    python
    python-numpy
    python-dbus
    ruff
    gcc
    typescript

    # Language Server
    python-lsp-server
    lua-language-server
    vscode-css-languageserver
    vscode-html-languageserver
    vscode-json-languageserver
    eslint-language-server

    # Virtualization (libvirt / virt-manager / spice)
    libvirt
    qemu-desktop
    virt-manager
    dnsmasq
    edk2-ovmf
    spice-gtk
    usbredir

    # glib / mounting / misc
    glib2
    udisks2
    gvfs
)

info_print "Installing programs via pacman"

# keeping the system up to date
pacman -Syuq

# the actual installing of the programs
for program in "${PROGRAMS[@]}"; do
    echo "installing $program"
    pacman -Sq --noconfirm $program
done