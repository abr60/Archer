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
EOF

# 3. Apply changes (Restarts if running live, Enables if running inside arch-chroot)
if systemctl is-system-running &>/dev/null; then
    sudo systemctl restart iwd
    sudo systemctl restart NetworkManager
    echo "Services restarted. MAC randomized."
else
    sudo systemctl enable iwd
    sudo systemctl enable NetworkManager
    echo "Services enabled for first boot."
fi
