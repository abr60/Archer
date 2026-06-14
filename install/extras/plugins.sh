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
hyprpm add "https://github.com/hyprwm/hyprland-plugins" || warn "Failed to add hyprland-plugins repo"

# ─── hyprexpo (sandwichfarm fork) ─────────────────────────────────────────────
msg "Adding hyprexpo (sandwichfarm fork)..."
hyprpm add "https://github.com/sandwichfarm/hyprexpo" || warn "Failed to add sandwichfarm/hyprexpo"

# ─── Enable plugins ───────────────────────────────────────────────────────────
hyprpm enable hyprexpo && ok "hyprexpo enabled" || warn "Failed to enable hyprexpo"

# ─── Reload ───────────────────────────────────────────────────────────────────
hyprpm reload && ok "Plugins reloaded" || warn "hyprpm reload failed"