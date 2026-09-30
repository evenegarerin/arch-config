#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring waybar"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    config_dir="/home/$username/.config"
    mkdir -p "$config_dir"

    if [[ -L "$config_dir/waybar" ]]; then
        rm "$config_dir/waybar"
    fi

    ln -sfn "$SCRIPT_DIR/waybar" "$config_dir/waybar"
done