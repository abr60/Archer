#!/usr/bin/env bash
# =============================================================================
# hardware/wifi-powersave.sh — Disable WiFi powersave on AC, enable on battery
# Uses udev rules to react to power supply changes automatically
# T14 Gen 2 specific — only runs if battery is present
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "WiFi Powersave Rules"

if ! has_battery; then
    warn "No battery detected — skipping WiFi powersave rules"
    exit 0
fi

RULES_FILE="/etc/udev/rules.d/99-archer-wifi-powersave.rules"
ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
WIFI_BIN="$ARCHER_DIR/bin/wifi-powersave"

if [[ -f "$RULES_FILE" ]]; then
    ok "WiFi powersave rules already installed — skipping"
    exit 0
fi

sudo tee "$RULES_FILE" > /dev/null << EOF
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="/usr/bin/systemd-run --no-block --collect --unit=archer-wifi-powersave-on $WIFI_BIN on"
SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="/usr/bin/systemd-run --no-block --collect --unit=archer-wifi-powersave-off $WIFI_BIN off"
EOF

sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=power_supply

ok "WiFi powersave rules installed"
ok "WiFi will disable powersave on AC, enable on battery"
