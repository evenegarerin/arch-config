#!/usr/bin/env -S bash -e

echo "configuring greetd"

cat > /etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "start-hyprland && read -n 1 -p Continue?; done"
user = "castle"
EOF

systemctl enable greetd.service