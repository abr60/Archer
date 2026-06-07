#!/usr/bin/env bash
# =============================================================================
# hardware/bluetooth.sh — Enable Bluetooth on boot
# Also sets up A2DP auto-connect via WirePlumber
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Bluetooth"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
BT_CONF="$ARCHER_DIR/default/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
WP_DEST="$HOME/.config/wireplumber/wireplumber.conf.d"

enable_system_service bluetooth.service

# A2DP autoconnect
if [[ -f "$BT_CONF" ]]; then
    mkdir -p "$WP_DEST"
    cp "$BT_CONF" "$WP_DEST/"
    ok "Bluetooth A2DP auto-connect configured"
else
    warn "bluetooth-a2dp-autoconnect.conf not found — skipping A2DP setup"
fi
