#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring kitty"

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    ff_policy_dst="/etc/firefox/policies"
    mkdir -p $ff_policy_dst

    ln -sfn "$SCRIPT_DIR/firefox/policies.json" "$ff_policy_dst/policies.json"
done