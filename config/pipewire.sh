#!/usr/bin/env -S bash -e

echo "setting up pipewire services"

systemctl --global enable pipewire.service
systemctl --global enable pipewire-pulse.service
systemctl --global enable wireplumber.service