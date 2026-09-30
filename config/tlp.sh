#!/usr/bin/env -S bash -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"

echo "configuring tlp"

mkdir -p /etc/tlp.d

cat > /etc/tlp.d/01-battery.conf <<'EOF'
START_CHARGE_THRESH_BAT0=80
STOP_CHARGE_THRESH_BAT0=95
EOF

systemctl enable --now tlp.service
tlp start