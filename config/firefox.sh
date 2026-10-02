#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring firefox"

ff_policy_dst="/etc/firefox/policies"
mkdir -p $ff_policy_dst

ln -sfn "$SCRIPT_DIR/firefox/policies.json" "$ff_policy_dst/policies.json"