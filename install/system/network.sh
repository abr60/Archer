#!/usr/bin/env bash
# =============================================================================
# system/network.sh — Network configuration tweaks
# - Disables systemd-networkd-wait-online (speeds up boot)
# - Enables iwd for improved WiFi management
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Network Configuration"

# Prevent systemd-networkd-wait-online from delaying boot
if systemctl is-enabled systemd-networkd-wait-online.service &>/dev/null; then
    sudo systemctl disable systemd-networkd-wait-online.service
    sudo systemctl mask systemd-networkd-wait-online.service
    ok "Disabled systemd-networkd-wait-online (faster boot)"
else
    ok "systemd-networkd-wait-online already disabled — skipping"
fi

# Enable iwd if installed
if is_installed iwd; then
    enable_system_service iwd.service
else
    warn "iwd not installed — skipping"
fi
