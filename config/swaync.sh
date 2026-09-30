#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring swaync"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    config_dir="/home/$username/.config"
    mkdir -p "$config_dir"

    if [[ -L "$config_dir/swaync" ]]; then
        rm "$config_dir/swaync"
    fi

    ln -sfn "$SCRIPT_DIR/swaync" "$config_dir/swaync"
done