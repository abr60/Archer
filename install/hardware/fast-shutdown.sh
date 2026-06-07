#!/usr/bin/env bash
# =============================================================================
# hardware/fast-shutdown.sh — Install faster shutdown systemd configs
# Reduces shutdown timeout from 90s to 10s
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Fast Shutdown"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
SRC_SYSTEM="$ARCHER_DIR/default/systemd/faster-shutdown.conf"
SRC_USER="$ARCHER_DIR/default/systemd/user@.service.d/faster-shutdown.conf"

DEST_SYSTEM="/etc/systemd/system.conf.d/10-faster-shutdown.conf"
DEST_USER="/etc/systemd/system/user@.service.d/faster-shutdown.conf"

if [[ -f "$DEST_SYSTEM" ]]; then
    ok "Fast shutdown already configured — skipping"
    exit 0
fi

if [[ ! -f "$SRC_SYSTEM" ]]; then
    warn "faster-shutdown.conf not found at $SRC_SYSTEM — skipping"
    exit 0
fi

sudo mkdir -p /etc/systemd/system.conf.d
sudo mkdir -p /etc/systemd/system/user@.service.d

sudo cp "$SRC_SYSTEM" "$DEST_SYSTEM"
ok "Installed system faster-shutdown.conf"

if [[ -f "$SRC_USER" ]]; then
    sudo cp "$SRC_USER" "$DEST_USER"
    ok "Installed user faster-shutdown.conf"
fi

sudo systemctl daemon-reload
ok "Systemd reloaded — shutdown timeout reduced"
