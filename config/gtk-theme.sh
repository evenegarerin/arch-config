#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring gtk 3 and 4 theme"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    config_dir="/home/$username/.config"
    mkdir -p "$config_dir"

    if [[ -L "$config_dir/gtk-3.0" ]]; then
        rm "$config_dir/gtk-3.0"
    fi

    if [[ -L "$config_dir/gtk-4.0" ]]; then
        rm "$config_dir/gtk-4.0"
    fi

    ln -sfn "$SCRIPT_DIR/gtk-3.0" "$config_dir/gtk-3.0"

    ln -sfn "$SCRIPT_DIR/gtk-4.0" "$config_dir/gtk-4.0"
done