#!/usr/bin/env bash
# =============================================================================
# extras/wallpapers.sh — Clone or update Wallpapers repository
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Wallpapers"

WALLPAPERS_DIR="$HOME/Wallpapers"
REPO_URL="https://github.com/drunk-particles/Wallpapers.git"

if [[ -d "$WALLPAPERS_DIR/.git" ]]; then
    msg "Wallpapers repo found — pulling latest..."
    if git -C "$WALLPAPERS_DIR" pull; then
        ok "Wallpapers updated"
    else
        warn "Pull failed — keeping existing wallpapers"
    fi
    exit 0
fi

if [[ -d "$WALLPAPERS_DIR" ]] && [[ -n "$(ls -A "$WALLPAPERS_DIR")" ]]; then
    warn "$WALLPAPERS_DIR exists and is not empty — skipping clone"
    exit 0
fi

spinner "Cloning Wallpapers..." git clone "$REPO_URL" "$WALLPAPERS_DIR" && \
    ok "Wallpapers cloned to $WALLPAPERS_DIR" || \
    { warn "Clone failed — check network connection"; exit 1; }
