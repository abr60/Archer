#!/usr/bin/env bash
set -e

echo "Setting up MAC address randomization..."

# 1. Create the configuration directory
sudo mkdir -p /etc/iwd

# 2. Write the working iwd configuration
sudo tee /etc/iwd/main.conf > /dev/null <<EOF
[General]
AddressRandomization=network
AddressRandomizationOnScan=true
EnableNetworkConfiguration=true

[Network]
NameResolvingServices=systemd
EnableIPv6=true
EOF

# 3. Apply changes (Restarts if running live, Enables if running inside arch-chroot)
if systemctl is-system-running &>/dev/null; then
    sudo systemctl restart iwd
    echo "iwd restarted. MAC randomized."
else
    sudo systemctl enable iwd
    echo "iwd enabled for first boot."
fi