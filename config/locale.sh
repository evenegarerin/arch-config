#!/usr/bin/env -S bash -e

echo "setting up locales"

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen

locale-gen

cat > /etc/locale.conf <<'EOF'
LANG=en_US.UTF-8

LC_ADDRESS=de_DE.UTF-8
LC_IDENTIFICATION=de_DE.UTF-8
LC_MEASUREMENT=de_DE.UTF-8
LC_MONETARY=de_DE.UTF-8
LC_NAME=de_DE.UTF-8
LC_NUMERIC=de_DE.UTF-8
LC_PAPER=de_DE.UTF-8
LC_TELEPHONE=de_DE.UTF-8
LC_TIME=de_DE.UTF-8
EOF

cat > /etc/vconsole.conf <<'EOF'
KEYMAP=de
EOF