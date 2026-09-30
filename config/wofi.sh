#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring wofi"

chmod +x "$SCRIPT_DIR/wofi/wofi-into-empty-workspace.sh"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    config_dir="/home/$username/.config"
    mkdir -p "$config_dir"

    if [[ -L "$config_dir/wofi" ]]; then
        rm "$config_dir/wofi"
    fi

    ln -sfn "$SCRIPT_DIR/wofi" "$config_dir/wofi"
done