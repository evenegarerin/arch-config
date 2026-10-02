#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring zsh"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    user_home="/home/$username"

    ln -sfn "$SCRIPT_DIR/zsh/.zshrc" "$user_home/.zshrc"
done
