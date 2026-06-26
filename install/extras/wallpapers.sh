#!/usr/bin/env bash
# =============================================================================
# extras/walls.sh — Clone/update Walls repository and link wallpapers to themes
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Walls"

WALLS_DIR="$HOME/Walls"
THEMES_DIR="$HOME/.local/share/Archer/Themes"
REPO_URL="https://github.com/drunk-particles/Walls.git"

# ─── Clone or Update ──────────────────────────────────────────────────────────

if [[ -d "$WALLS_DIR/.git" ]]; then
    msg "Walls repo found — pulling latest..."
    if git -C "$WALLS_DIR" pull; then
        ok "Walls updated"
    else
        warn "Pull failed — keeping existing Walls"
    fi
else
    if [[ -d "$WALLS_DIR" ]] && [[ -n "$(ls -A "$WALLS_DIR")" ]]; then
        warn "$WALLS_DIR exists and is not empty — skipping clone"
    else
        spinner "Cloning Walls..." git clone "$REPO_URL" "$WALLS_DIR" && \
            ok "Walls cloned to $WALLS_DIR" || \
            { warn "Clone failed — check network connection"; exit 1; }
    fi
fi

# ─── Link wallpaper folders to matching themes ────────────────────────────────

if [[ ! -d "$THEMES_DIR" ]]; then
    warn "Themes directory not found: $THEMES_DIR"
    exit 0
fi

msg "Linking wallpaper directories..."

find "$THEMES_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r theme_dir; do
    theme_name="$(basename "$theme_dir")"

    source_dir="$WALLS_DIR/$theme_name"
    target_link="$theme_dir/Walls"

    if [[ -d "$source_dir" ]]; then
        ln -sfn "$source_dir" "$target_link"
        ok "Linked $theme_name"
    else
        warn "No wallpapers found for theme '$theme_name'"
    fi
done

ok "Wallpaper links are up to date."