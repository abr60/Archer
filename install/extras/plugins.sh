#!/usr/bin/env bash
# =============================================================================
# extras/plugins.sh — Install Hyprland plugins via hyprpm
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Hyprland Plugins"

if ! command -v hyprpm &>/dev/null; then
    warn "hyprpm not found — skipping plugin setup"
    exit 0
fi

spinner "Updating hyprpm..." hyprpm update || warn "hyprpm update failed — continuing"

PLUGIN_URL="https://github.com/hyprwm/hyprland-plugins"
msg "Adding hyprland-plugins repo..."
hyprpm add "$PLUGIN_URL" || { warn "Failed to add hyprland-plugins repo"; exit 0; }

hyprpm enable hyprexpo && ok "hyprexpo enabled" || warn "Failed to enable hyprexpo"
hyprpm reload && ok "Plugins reloaded" || warn "hyprpm reload failed"
