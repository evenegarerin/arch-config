#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring zsh"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    if [[ -L "$config_dir/.zshrc" ]]; then
        rm "$config_dir/.zshrc"
    fi

    ln -sfn "$SCRIPT_DIR/zsh/.zshrc" "$config_dir/.zshrc"
done