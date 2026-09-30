#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring vscodium"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    config_dir="/home/$username/.config"
    mkdir -p "$config_dir"

    if [[ -L "$config_dir/vscodium" ]]; then
        rm "$config_dir/vscodium"
    fi

    ln -sfn "$SCRIPT_DIR/vscodium/settings.json" "$config_dir/VSCodium/User/settings.json"
done