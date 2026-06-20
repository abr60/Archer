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

# ─── hyprland-plugins (official) ──────────────────────────────────────────────
msg "Adding hyprland-plugins repo..."
hyprpm add "https://github.com/hyprwm/hyprland-plugins" || warn "Failed to add hyprland-plugins"

# ─── scrolloverview ───────────────────────────────────────────────────────────
msg "Adding scrolloverview..."
hyprpm add "https://github.com/TentacleSama4254/scrolloverview" || warn "Failed to add scrolloverview"

# ─── Enable plugins ───────────────────────────────────────────────────────────
hyprpm enable scrolloverview && ok "scrolloverview enabled" || warn "Failed to enable scrolloverview"

# ─── Reload ───────────────────────────────────────────────────────────────────
hyprpm reload && ok "Plugins reloaded" || warn "hyprpm reload failed"