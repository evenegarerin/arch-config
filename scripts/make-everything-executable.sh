#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

chmod +x $SCRIPT_DIR/../config/*sh
chmod +x $SCRIPT_DIR/../programs/*sh
chmod +x $SCRIPT_DIR/../scripts/*sh