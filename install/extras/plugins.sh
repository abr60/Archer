#!/usr/bin/env bash
# =============================================================================
# extras/plugins.sh — Install hyprexpo plugin via hyprpm
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

PLUGINS_LUA="$HOME/.config/hypr/plugins.lua"
AUTOSTART_LUA="$HOME/.config/hypr/autostart.lua"

if [[ "${1:-}" != "--clean" ]]; then
    [[ ! -f "$PLUGINS_LUA" ]]   && die "plugins.lua not found at $PLUGINS_LUA"
    [[ ! -f "$AUTOSTART_LUA" ]] && die "autostart.lua not found at $AUTOSTART_LUA"
fi

# ─── Clean Mode ───────────────────────────────────────────────────────────────
if [[ "${1:-}" == "--clean" ]]; then
    section "Cleaning Hyprexpo Plugin"
    CLEAN_TOTAL=3; CLEAN_STEP=0
    step() { (( CLEAN_STEP++ )) || true; msg "[$CLEAN_STEP/$CLEAN_TOTAL] $*"; }

    step "Disabling and removing hyprexpo..."
    hyprpm disable hyprexpo 2>/dev/null && ok "hyprexpo disabled" || true
    hyprpm remove  hyprexpo 2>/dev/null && ok "hyprexpo removed"  || true

    step "Re-commenting hyprexpo in plugins.lua..."
    if grep -q '^require("hypr.plugins.hyprexpo")' "$PLUGINS_LUA"; then
        sed -i 's|^require("hypr.plugins.hyprexpo")|--require("hypr.plugins.hyprexpo")|' "$PLUGINS_LUA"
        ok "Done"
    else
        ok "Already commented — skipping"
    fi

    step "Removing hyprpm reload from autostart.lua..."
    if grep -q 'hyprpm reload' "$AUTOSTART_LUA"; then
        sed -i '/hyprpm reload/d' "$AUTOSTART_LUA"
        ok "Done"
    else
        ok "Not present — skipping"
    fi

    exit 0
fi

# ─── Normal Install Mode ──────────────────────────────────────────────────────
section "Hyprexpo Plugin"
sudo-keepalive &
TOTAL=6; STEP=0
step() { (( STEP++ )) || true; msg "[$STEP/$TOTAL] $*"; }

step "Checking hyprpm build dependencies..."
if ! is_installed cmake; then
    bash "$(dirname "${BASH_SOURCE[0]}")/../packaging/packages" extra --tag Hyprpm
    ok "Dependencies installed"
else
    ok "Already installed — skipping"
fi

if ! command -v hyprpm &>/dev/null; then
    warn "hyprpm not found — aborting"
    exit 0
fi

step "Updating hyprpm..."
hyprpm update && ok "Done" || warn "hyprpm update failed — continuing"

step "Adding hyprexpo repo..."
hyprpm add "https://github.com/sandwichfarm/hyprexpo" 2>/dev/null || true
ok "Done"

step "Enabling hyprexpo..."
hyprpm enable hyprexpo && ok "Done" || warn "Failed to enable hyprexpo"
hyprpm reload          && ok "Plugins reloaded" || warn "hyprpm reload failed"

step "Updating plugins.lua..."
if grep -q '^--require("hypr.plugins.hyprexpo")' "$PLUGINS_LUA"; then
    sed -i 's|^--require("hypr.plugins.hyprexpo")|require("hypr.plugins.hyprexpo")|' "$PLUGINS_LUA"
    ok "Uncommented hyprexpo"
elif grep -q '^require("hypr.plugins.hyprexpo")' "$PLUGINS_LUA"; then
    ok "Already active — skipping"
else
    warn "hyprexpo line not found in plugins.lua — add it manually"
fi

step "Updating autostart.lua..."
if ! grep -q 'hyprpm reload' "$AUTOSTART_LUA"; then
    echo 'a.exec_on_start("hyprpm reload")  -- Reload plugins on every boot' >> "$AUTOSTART_LUA"
    ok "Injected hyprpm reload"
else
    ok "Already present — skipping"
fi

hyprctl reload && ok "Hyprland reloaded" || warn "hyprctl reload failed"