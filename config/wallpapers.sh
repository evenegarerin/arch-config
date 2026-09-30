#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "linking wallpapers"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    config_dir="/home/$username/.config"
    mkdir -p "$config_dir"

    if [[ -L "$config_dir/wallpapers" ]]; then
        rm "$config_dir/wallpapers"
    fi

    ln -sfn "$SCRIPT_DIR/wallpapers" "$config_dir/wallpapers"
done