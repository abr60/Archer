#!/usr/bin/env bash
# =============================================================================
# config/dotfiles.sh — Symlink config/ → ~/.config via GNU Stow
# Also ensures script permissions are set correctly
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/backup.sh"

section "Config Symlinks (Stow)"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
CONFIG_DEST="$HOME/.config"

ensure_installed stow

if [[ ! -d "$ARCHER_DIR/config" ]]; then
    die "$ARCHER_DIR/config not found — cannot stow"
fi

load_backup_session

# ─── Remove existing configs that overlap ─────────────────────────────────────
STOW_DIRS=(
    btop cava fastfetch ghostty hypr
    matugen mpv rmpc rofi sioyek
    spicetify swaync swayosd tmux
    uwsm walker waybar
)

msg "Removing existing config dirs that overlap..."
for dir in "${STOW_DIRS[@]}"; do
    target="$CONFIG_DEST/$dir"
    if [[ -e "$target" || -L "$target" ]]; then
        backup_file "$target"
        remove_path "$target"
        ok "Cleared: $target"
    fi
done

# Remove starship.toml if present
if [[ -e "$CONFIG_DEST/starship.toml" ]]; then
    backup_file "$CONFIG_DEST/starship.toml"
    rm -f "$CONFIG_DEST/starship.toml"
    ok "Cleared: starship.toml"
fi

# ─── Stow ─────────────────────────────────────────────────────────────────────
msg "Running stow..."
cd "$ARCHER_DIR"
stow --target="$HOME/.config" config
ok "Stow complete — ~/.config entries symlinked from $ARCHER_DIR/config"

# ─── Script permissions ───────────────────────────────────────────────────────
find "$CONFIG_DEST/hypr/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
ok "Script permissions updated"

# ─── Output directories ───────────────────────────────────────────────────────
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Videos/Screen Recordings"
ok "Output directories created"
