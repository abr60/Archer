#!/usr/bin/env bash
# =============================================================================
# extras/themes.sh — Symlink themes → ~/.config/Archer/themes
# Symlinks wallpaper folders from ~/Wallpapers/backgrounds/<theme>/
# NOTE: Theming system is not fully built yet — this sets up the structure
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Themes"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
THEME_SOURCE="$ARCHER_DIR/themes"
THEME_DEST="$HOME/.config/Archer/themes"
WALLPAPERS_BASE="$HOME/Wallpapers/backgrounds"

if [[ ! -d "$THEME_SOURCE" ]]; then
    warn "No themes folder found at $THEME_SOURCE — skipping"
    exit 0
fi

mkdir -p "$THEME_DEST"

# ─── Symlink themes ───────────────────────────────────────────────────────────
found=0
for theme_dir in "$THEME_SOURCE"/*/; do
    theme_name=$(basename "$theme_dir")
    theme_link="$THEME_DEST/$theme_name"
    remove_path "$theme_link"
    ln -s "$theme_dir" "$theme_link"
    ok "Symlinked $theme_name"
    (( found++ )) || true
done

[[ "$found" -eq 0 ]] && warn "No themes found in $THEME_SOURCE" || ok "$found theme(s) symlinked"

# ─── Symlink wallpapers ───────────────────────────────────────────────────────
if [[ ! -d "$WALLPAPERS_BASE" ]]; then
    warn "Wallpapers not found at $WALLPAPERS_BASE — skipping wallpaper symlinks"
    exit 0
fi

found=0
for theme_wallpaper_dir in "$WALLPAPERS_BASE"/*/; do
    theme_name=$(basename "$theme_wallpaper_dir")
    backgrounds_link="$THEME_DEST/$theme_name/backgrounds"
    remove_path "$backgrounds_link"
    mkdir -p "$THEME_DEST/$theme_name"
    ln -s "$theme_wallpaper_dir" "$backgrounds_link"
    ok "Wallpapers symlinked for $theme_name"
    (( found++ )) || true
done

[[ "$found" -eq 0 ]] && warn "No wallpaper folders found" || ok "Wallpapers symlinked for $found theme(s)"
