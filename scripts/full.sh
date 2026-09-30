#!/usr/bin/env -S bash -e

# this script calls "./programs.sh" and "./config.sh"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# calling the other scripts
"$SCRIPT_DIR/programs.sh"

"$SCRIPT_DIR/config.sh"