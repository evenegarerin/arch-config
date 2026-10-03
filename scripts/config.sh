#!/usr/bin/env -S bash -e

# this script calls all top level shell script in "../config"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

info_print "Configuring the system"

find "$SCRIPT_DIR/../config" -maxdepth 1 -type f -name '*.sh' -print0 |
while IFS= read -r -d '' script; do
    "$script"
done

for user in "${USERS[@]}"; do
    read -r username sudo <<< "$user"

    chown -R $username:$username /home/$username/.config
done

info_print "Fully configured the system"