#!/usr/bin/env bash
# =============================================================================
# extras/thinkfan.sh — Configure Thinkfan for ThinkPad T14 Gen 2
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Thinkfan"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
CONF_SRC="$ARCHER_DIR/system/thinkfan/thinkfan.conf"

if ! is_installed thinkfan; then
    warn "thinkfan not installed — skipping"
    exit 0
fi

# Enable fan control via thinkpad_acpi
echo "options thinkpad_acpi fan_control=1" | \
    sudo tee /etc/modprobe.d/thinkpad_acpi.conf > /dev/null
ok "thinkpad_acpi fan_control enabled"

# Install config
if [[ -f "$CONF_SRC" ]]; then
    sudo cp "$CONF_SRC" /etc/thinkfan.conf
    ok "thinkfan.conf installed"
else
    warn "thinkfan.conf not found at $CONF_SRC — skipping config"
fi

ok "Thinkfan setup complete — service will be enabled by system-services.sh"
