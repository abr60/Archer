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
hyprpm add "https://github.com/yayuuu/hyprland-scroll-overview" || warn "Failed to add scrolloverview"

# ─── Enable plugins ───────────────────────────────────────────────────────────
hyprpm enable scrolloverview && ok "scrolloverview enabled" || warn "Failed to enable scrolloverview"

# ─── Reload ───────────────────────────────────────────────────────────────────
hyprpm reload && ok "Plugins reloaded" || warn "hyprpm reload failed"

# ─── Inject into hyprland.lua ─────────────────────────────────────────────────
HYPR_LUA="$HOME/.config/hypr/hyprland.lua"
if ! grep -q 'require("hypr.plugins")' "$HYPR_LUA"; then
    sed -i '/require("hypr.gestures")/i require("hypr.plugins")' "$HYPR_LUA"
    ok "Injected require(\"hypr.plugins\") into hyprland.lua"
fi

# ─── Inject plugin bindings into bindings.lua ─────────────────────────────────
BINDINGS="$HOME/.config/hypr/bindings.lua"
if ! grep -q 'scrolloverview' "$BINDINGS"; then
    cat >> "$BINDINGS" << 'EOF'

-- === Plugin Bindings ===
hl.bind("HOME", hl.dsp.exec_cmd("scrolloverview:overview toggle"))
EOF
    ok "Injected plugin bindings into bindings.lua"
fi

# ─── Reload Hyprland ──────────────────────────────────────────────────────────
hyprctl reload && ok "Hyprland reloaded" || warn "hyprctl reload failed"