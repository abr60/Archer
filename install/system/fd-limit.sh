#!/usr/bin/env bash
# =============================================================================
# system/fd-limit.sh — Raise file descriptor limits
# Raises soft limit from systemd's default 1024 to 65536
# so dev tools (VSCode, node, databases) get the headroom they need
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "File Descriptor Limits"

CONF_SYSTEM="/etc/systemd/system.conf.d/99-archer-nofile.conf"
CONF_USER="/etc/systemd/user.conf.d/99-archer-nofile.conf"

if [[ -f "$CONF_SYSTEM" ]]; then
    ok "fd-limit already configured — skipping"
    exit 0
fi

sudo mkdir -p /etc/systemd/system.conf.d /etc/systemd/user.conf.d

sudo tee "$CONF_SYSTEM" > /dev/null << 'EOF'
[Manager]
DefaultLimitNOFILE=65536:524288
EOF

sudo cp "$CONF_SYSTEM" "$CONF_USER"

ok "File descriptor limits raised to 65536:524288"
warn "Takes effect on next reboot"
