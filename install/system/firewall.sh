#!/usr/bin/env bash
# =============================================================================
# system/firewall.sh — Configure UFW firewall
# Deny all incoming, allow outgoing
# Opens ports for LocalSend and SSH
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Firewall (UFW)"

if ! is_installed ufw; then
    warn "ufw not installed — skipping"
    exit 0
fi

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing
ok "Default policies set (deny in, allow out)"

# LocalSend (file sharing on LAN)
sudo ufw allow 53317/udp comment 'LocalSend'
sudo ufw allow 53317/tcp comment 'LocalSend'
ok "LocalSend ports opened (53317)"

# SSH
sudo ufw allow 22/tcp comment 'SSH'
ok "SSH port opened (22)"

# Enable firewall
sudo ufw --force enable
ok "UFW enabled"

# Enable on boot
sudo systemctl enable ufw
ok "UFW enabled on boot"
