#!/usr/bin/env bash
# =============================================================================
# services/reload.sh — Reload Hyprland and restart key components
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Reloading UI"

# Reload Hyprland config
hyprctl reload 2>/dev/null && ok "Hyprland reloaded" || warn "Hyprland not running — skipping"

# Restart Waybar
if pgrep -x waybar &>/dev/null; then
    pkill waybar 2>/dev/null || true
    sleep 0.5
    uwsm-app -- waybar &disown 2>/dev/null && ok "Waybar restarted" || warn "Waybar failed to restart"
else
    warn "Waybar not running — skipping"
fi

# Restart Walker
if command -v walker &>/dev/null; then
    pkill walker 2>/dev/null || true
    ok "Walker stopped (will restart on next invoke)"
fi

ok "UI reload complete"
