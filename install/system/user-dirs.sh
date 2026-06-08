#!/usr/bin/env bash
# =============================================================================
# system/user-dirs.sh — Set up standard user directories
# Creates useful dirs, removes clutter (Desktop, Templates, Public)
# Adds Nautilus bookmarks
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "User Directories"

# Create useful dirs
mkdir -p \
    "$HOME/Downloads" \
    "$HOME/Pictures" \
    "$HOME/Pictures/Screenshots" \
    "$HOME/Videos" \
    "$HOME/Videos/Screen Recordings" \
    "$HOME/Projects" \
    "$HOME/.config/gtk-3.0"

ok "Created standard directories"

# Remove XDG clutter
xdg-user-dirs-update --set TEMPLATES "$HOME"  2>/dev/null || true
xdg-user-dirs-update --set PUBLICSHARE "$HOME" 2>/dev/null || true
xdg-user-dirs-update --set DESKTOP "$HOME"    2>/dev/null || true

rmdir "$HOME/Templates" "$HOME/Public" "$HOME/Desktop" 2>/dev/null || true
ok "Removed Desktop, Templates, Public clutter"

# Nautilus bookmarks
BOOKMARKS="$HOME/.config/gtk-3.0/bookmarks"
touch "$BOOKMARKS"

for dir in Downloads Projects Pictures Videos; do
    entry="file://$HOME/$dir $dir"
    grep -qF "$entry" "$BOOKMARKS" || echo "$entry" >> "$BOOKMARKS"
done

ok "Nautilus bookmarks set"
