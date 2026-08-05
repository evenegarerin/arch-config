#!/usr/bin/env -S bash -e

# this is an arch install script, based of my original nixos setup

# Cleaning the TTY.
clear

# Cosmetics (colours for text).
BOLD='\e[1m'
BRED='\e[91m'
BBLUE='\e[34m'  
BGREEN='\e[92m'
BYELLOW='\e[93m'
RESET='\e[0m'

# Pretty print (function).
info_print () {
    echo -e "${BOLD}${BGREEN}[ ${BYELLOW}•${BGREEN} ] $1${RESET}"
}

# Pretty print for input (function).
input_print () {
    echo -ne "${BOLD}${BYELLOW}[ ${BGREEN}•${BYELLOW} ] $1${RESET}"
}

# Alert user of bad input (function).
error_print () {
    echo -e "${BOLD}${BRED}[ ${BBLUE}•${BRED} ] $1${RESET}"
}

# User chooses the console keyboard layout (function).
keyboard_selector () {
    input_print "Please insert the keyboard layout to use in console (enter empty to use US, or \"/\" to look up for keyboard layouts): "
    read -r kblayout
    case "$kblayout" in
        '') kblayout="us"
            info_print "The standard US keyboard layout will be used."
            return 0;;
        '/') localectl list-keymaps
             clear
             return 1;;
        *) if ! localectl list-keymaps | grep -Fxq "$kblayout"; then
               error_print "The specified keymap doesn't exist."
               return 1
           fi
        info_print "Changing console layout to $kblayout."
        loadkeys "$kblayout"
        return 0
    esac
}

# User enters a hostname (function).
hostname_selector () {
    input_print "Please enter the hostname: "
    read -r hostname
    if [[ -z "$hostname" ]]; then
        error_print "You need to enter a hostname in order to continue."
        return 1
    fi
    return 0
}

# Requesting the to be used password for a user (function).
user_password_selector () {
    input_print "Please enter a password for $1 (you're not going to see it): "
    read -r -s password
    if [[ -z "$password" ]]; then
        echo
        error_print "You need to enter a password for the $1 user, please try again."
        return 1
    fi
    echo
    input_print "Please enter the password again (you're not going to see it): " 
    read -r -s password2
    echo
    if [[ "$password" != "$password2" ]]; then
        error_print "Passwords don't match, please try again."
        return 1
    fi
    return 0
}

# User creator (function).
user_creator () {
    username=$1
    user_sudo=$2

    until user_password_selector "$username"; do : ; done

    user_password=$password

    info_print "Creating user $username."

    user_args=(
        -m
        -s /bin/zsh
    )

    if [[ "$user_sudo" == "true" ]]; then
        user_args+=(-G wheel)
    fi

    arch-chroot /mnt useradd "${user_args[@]}" "$username"

    echo "$username:$user_password" | arch-chroot /mnt chpasswd
}

# Microcode detector (function).
microcode_detector () {
    CPU=$(grep vendor_id /proc/cpuinfo)
    if [[ "$CPU" == *"AuthenticAMD"* ]]; then
        info_print "An AMD CPU has been detected, the AMD microcode will be installed."
        microcode="amd-ucode"
    else
        info_print "An Intel CPU has been detected, the Intel microcode will be installed."
        microcode="intel-ucode"
    fi
}

# start
info_print "this is an arch install script, some of the steps will make irreversible changes to this machine"

info_print "confirming internet connection, this might take a moment."

ping -c 1 archlinux.org >/dev/null || {
    error_print "No internet connection."
    exit 1
}

# Setting up keyboard layout.
until keyboard_selector; do : ; done

# Choosing the target for the installation.
info_print "Available disks for the installation:"
mapfile -t ARR < <(lsblk -dpno NAME,SIZE,MODEL | grep -P "/dev/sd|nvme|vd");
PS3="Please select the number of the corresponding disk (e.g. 1): "
select ENTRY in "${ARR[@]}";
do
    DISK=$(echo "$ENTRY" | awk '{print $1}')
    info_print "Arch Linux will be installed on the following disk: $DISK"
    break
done

# User choses the hostname.
until hostname_selector; do : ; done

# Detects required microcode
microcode_detector

# Warn user about deletion of old partition scheme.
input_print "This will delete the current partition table on $DISK once installation starts. Do you agree [y/N]?: "
read -r disk_response
if ! [[ "${disk_response,,}" =~ ^(yes|y)$ ]]; then
    error_print "Quitting."
    exit
fi
info_print "Wiping $DISK."
wipefs -af "$DISK" &>/dev/null
sgdisk -Zo "$DISK" &>/dev/null

# Creating a new partition scheme.
info_print "Creating the partitions on $DISK."
parted -s "$DISK" \
    mklabel gpt \
    mkpart ESP fat32 1MiB 1025MiB \
    set 1 esp on \
    mkpart ROOT ext4 1025MiB 100%

ESP="/dev/disk/by-partlabel/ESP"
ROOT="/dev/disk/by-partlabel/ROOT"

# Informing the kernel of the changes.
info_print "Informing the kernel about the disk changes."
partprobe "$DISK"

# Formatting the ESP.
info_print "Formatting the EFI Partition as FAT32."
mkfs.fat -F32 "$ESP"

# Formatting the root partition.
info_print "Formatting the root partition as ext4."
mkfs.ext4 "$ROOT"

# Mounting the root partition.
mount "$ROOT" /mnt

# Mount the ESP.
mkdir -p /mnt/boot
mount "$ESP" /mnt/boot

# Creating normal filesystem directories.
mkdir -p /mnt/{home,root,srv}
chmod 750 /mnt/root

# Installing base system.
info_print "Installing the base system."
pacstrap -K /mnt \
    base \
    base-devel \
    linux-lts \
    "$microcode" \
    linux-firmware \
    linux-lts-headers \
    grub \
    rsync \
    efibootmgr \
    reflector \
    zram-generator \
    sudo \
    zsh \
    zsh-syntax-highlighting \
    git \
    networkmanager \
    pkgfile

# Setting hostname.
echo "$hostname" > /mnt/etc/hostname

# Generating fstab.
info_print "Generating fstab."
genfstab -U /mnt >> /mnt/etc/fstab

# Locale configuration.
sed -i \
  -e '/^#en_US.UTF-8/s/^#//' \
  -e '/^#de_DE.UTF-8/s/^#//' \
  /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

cat > /mnt/etc/locale.conf <<EOF
LANG=en_US.UTF-8
LC_ADDRESS=de_DE.UTF-8
LC_IDENTIFICATION=de_DE.UTF-8
LC_MEASUREMENT=de_DE.UTF-8
LC_MONETARY=de_DE.UTF-8
LC_NAME=de_DE.UTF-8
LC_NUMERIC=de_DE.UTF-8
LC_PAPER=de_DE.UTF-8
LC_TELEPHONE=de_DE.UTF-8
LC_TIME=de_DE.UTF-8
EOF

echo "KEYMAP=$kblayout" > /mnt/etc/vconsole.conf

# Hosts file.
info_print "Setting hosts file."
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain   $hostname
EOF

# GRUB configuration.
info_print "Configuring GRUB."

UUID=$(blkid -s UUID -o value "$ROOT")

sed -i "s|^GRUB_CMDLINE_LINUX=.*|GRUB_CMDLINE_LINUX=\"root=UUID=$UUID\"|" /mnt/etc/default/grub

# ZRAM configuration.
info_print "Configuring ZRAM."

cat > /mnt/etc/systemd/zram-generator.conf <<EOF
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd
EOF


# Configure system inside chroot.
info_print "Configuring installed system."

arch-chroot /mnt /bin/bash -e <<EOF
    # Timezone.
    ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

    # Hardware clock.
    hwclock --systohc

    # Generate locales.
    locale-gen

    pkgfile --update

    if [[ ! -d /usr/share/oh-my-zsh ]]; then
        git clone \
            --depth=1 \
            https://github.com/ohmyzsh/ohmyzsh.git \
            /usr/share/oh-my-zsh
    fi

    mkinitcpio -P

    # Install GRUB.
    grub-install \
        --target=x86_64-efi \
        --efi-directory=/boot \
        --bootloader-id=GRUB \
        --removable

    # Generate GRUB config.
    grub-mkconfig -o /boot/grub/grub.cfg
EOF

# managing user rights
arch-chroot /mnt passwd -l root

echo "%wheel ALL=(ALL:ALL) ALL" > /mnt/etc/sudoers.d/wheel
chmod 440 /mnt/etc/sudoers.d/wheel

# creating users
cat > /mnt/etc/skel/.zshrc <<'EOF'
export ZSH=/usr/share/oh-my-zsh

ZSH_THEME="af-magic"

plugins=(
    command-not-found
    git
    history
    sudo
)

source "$ZSH/oh-my-zsh.sh"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

user_creator castle false
user_creator admin true

# Pacman improvements.
info_print "Configuring pacman."

sed -Ei \
    's/^#(Color)$/\1\nILoveCandy/;s/^#(ParallelDownloads).*/\1 = 10/' \
    /mnt/etc/pacman.conf


# Enable services.
info_print "Enabling services."

services=(
    reflector.timer
    systemd-oomd.service
    NetworkManager
)

for service in "${services[@]}"; do
    systemctl enable "$service" --root=/mnt
done

umount -R /mnt

# finish
info_print "Installation complete. You may reboot."

