#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring vscodium"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    config_dir="/home/$username/.config/vscodium/User"
    mkdir -p "$config_dir"

    ln -sfn "$SCRIPT_DIR/vscodium/settings.json" "$config_dir/settings.json"
done