#!/usr/bin/env bash
# =============================================================================
# extras/plugins.sh — Install Hyprland plugins via hyprpm
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

HYPR_LUA="$HOME/.config/hypr/hyprland.lua"
BINDINGS="$HOME/.config/hypr/bindings.lua"

# ─── Clean Mode (Triggered by --clean) ────────────────────────────────────────
if [[ "${1:-}" == "--clean" ]]; then
    section "Cleaning Hyprland Plugin Configs"
    
    # Remove the require line from hyprland.lua
    if grep -q 'require("hypr.plugins")' "$HYPR_LUA"; then
        sed -i '/require("hypr.plugins")/d' "$HYPR_LUA"
        ok "Removed require(\"hypr.plugins\") from hyprland.lua"
    fi

    # Remove the bindings block from bindings.lua
    if grep -q 'scrolloverview' "$BINDINGS"; then
        # Deletes the specific comment and the bind line
        sed -i '/-- === Plugin Bindings ===/d' "$BINDINGS"
        sed -i '/scrolloverview:overview toggle/d' "$BINDINGS"
        # Clean up any trailing blank lines left behind
        sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$BINDINGS"
        ok "Removed plugin bindings from bindings.lua"
    fi
    
    exit 0
fi

# ─── Normal Install Mode ──────────────────────────────────────────────────────
section "Hyprland Plugins"

# -----------------------------------------------------------------------------
# Install Hyprpm development dependencies via the tagged package list
# -----------------------------------------------------------------------------
if ! is_installed cmake || ! is_installed hyprland-headers; then
    msg "Installing hyprpm build dependencies via tags..."
    bash "$(dirname "${BASH_SOURCE[0]}")/../packaging/packages" extra --tag Hyprpm
fi

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
if ! grep -q 'require("hypr.plugins")' "$HYPR_LUA"; then
    sed -i '/require("hypr.gestures")/i require("hypr.plugins")' "$HYPR_LUA"
    ok "Injected require(\"hypr.plugins\") into hyprland.lua"
fi

# ─── Inject plugin bindings into bindings.lua ─────────────────────────────────
if ! grep -q 'scrolloverview' "$BINDINGS"; then
    cat >> "$BINDINGS" << 'EOF'

-- === Plugin Bindings ===
hl.bind("HOME", hl.dsp.exec_cmd("scrolloverview:overview toggle"))
EOF
    ok "Injected plugin bindings into bindings.lua"
fi

# ─── Reload Hyprland ──────────────────────────────────────────────────────────
hyprctl reload && ok "Hyprland reloaded" || warn "hyprctl reload failed"