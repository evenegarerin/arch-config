#!/usr/bin/env -S bash -e

# this script calls all top level shell script in "../programs"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

# calling all scripts
info_print "Installing programs to the system"

find "$SCRIPT_DIR/../programs" -maxdepth 1 -type f -name '*.sh' -print0 |
while IFS= read -r -d '' script; do
    "$script"
done