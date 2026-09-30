#!/usr/bin/env -S bash -e

# this script calls all top level shell script in "../config"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

info_print "Configuring the system"