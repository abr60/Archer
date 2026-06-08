#!/usr/bin/env bash
# =============================================================================
# system/ssh-flakiness.sh — Fix common SSH connection flakiness
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "SSH Flakiness Fix"

CONF="/etc/sysctl.d/99-archer-ssh.conf"

if [[ -f "$CONF" ]]; then
    ok "SSH fix already applied — skipping"
    exit 0
fi

echo "net.ipv4.tcp_mtu_probing=1" | sudo tee "$CONF" > /dev/null
sudo sysctl --system > /dev/null 2>&1

ok "TCP MTU probing enabled — SSH connections will be more stable"
