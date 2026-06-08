#!/usr/bin/env bash
# =============================================================================
# config/applications.sh — Install desktop apps, icons, and batty binary
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Applications"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
APPS_SRC="$ARCHER_DIR/applications"
SYSTEM_APPS_SRC="$ARCHER_DIR/system/applications"
DESKTOP_DIR="$HOME/.local/share/applications"
ICONS_DIR="$HOME/.local/share/icons/hicolor/48x48/apps"
BIN_SOURCE="$ARCHER_DIR/bin/batty"
BIN_DEST="$HOME/.cargo/bin"

# ─── batty binary ─────────────────────────────────────────────────────────────
if [[ -f "$BIN_SOURCE" ]]; then
    mkdir -p "$BIN_DEST"
    cp -f "$BIN_SOURCE" "$BIN_DEST/"
    chmod +x "$BIN_DEST/batty"
    ok "batty installed to $BIN_DEST"
else
    warn "batty binary not found at $BIN_SOURCE — skipping"
fi

# ─── Desktop files ────────────────────────────────────────────────────────────
mkdir -p "$DESKTOP_DIR" "$ICONS_DIR"

# User webapps
if [[ -d "$APPS_SRC" ]]; then
    count=$(find "$APPS_SRC" -maxdepth 1 -name "*.desktop" | wc -l)
    if [[ "$count" -gt 0 ]]; then
        cp "$APPS_SRC"/*.desktop "$DESKTOP_DIR/"
        ok "Copied $count user .desktop files"
    fi
fi

# System desktop files
if [[ -d "$SYSTEM_APPS_SRC" ]]; then
    count=$(find "$SYSTEM_APPS_SRC" -maxdepth 1 -name "*.desktop" | wc -l)
    if [[ "$count" -gt 0 ]]; then
        cp "$SYSTEM_APPS_SRC"/*.desktop "$DESKTOP_DIR/"
        ok "Copied $count system .desktop files"
    fi

    # Hidden desktop overrides
    if [[ -d "$SYSTEM_APPS_SRC/hidden" ]]; then
        cp "$SYSTEM_APPS_SRC/hidden"/*.desktop "$DESKTOP_DIR/"
        ok "Copied hidden desktop overrides"
    fi
fi

# ─── Icons ────────────────────────────────────────────────────────────────────
for icon_src in "$APPS_SRC/icons" "$SYSTEM_APPS_SRC/icons"; do
    if [[ -d "$icon_src" ]]; then
        count=$(find "$icon_src" -maxdepth 1 -type f | wc -l)
        if [[ "$count" -gt 0 ]]; then
            cp "$icon_src"/* "$ICONS_DIR/"
            ok "Copied $count icons from $(basename "$(dirname "$icon_src")")/icons"
        fi
    fi
done

# ─── Update caches ────────────────────────────────────────────────────────────
update-desktop-database "$DESKTOP_DIR" 2>/dev/null && ok "Desktop database updated" || true
gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null && ok "Icon cache updated" || true
