#!/usr/bin/env bash
# =============================================================================
# config/dotfiles.sh — Symlink config/ → ~/.config via GNU Stow
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Config Symlinks (Stow)"

# Resolve real path — Stow doesn't handle symlinked source dirs reliably
ARCHER_REAL="$(realpath "$HOME/Archer")"
CONFIG_DEST="$HOME/.config"

ensure_installed stow

if [[ ! -d "$ARCHER_REAL/config" ]]; then
    die "$ARCHER_REAL/config not found — cannot stow"
fi

# ─── All subdirs present in config/ that should be stowed ────────────────────
STOW_DIRS=(
    autostart btop cava calibre fastfetch fcitx5 fontconfig
    ghostty hypr matugen mpv rmpc
    rofi sioyek spicetify swaync swayosd
    systemd tmux uwsm walker waybar
)

# ─── Remove existing targets to prevent Stow fold conflicts ──────────────────
msg "Clearing existing config targets..."
for dir in "${STOW_DIRS[@]}"; do
    target="$CONFIG_DEST/$dir"
    if [[ -e "$target" || -L "$target" ]]; then
        remove_path "$target"
        ok "Cleared: $target"
    fi
done

# starship.toml lives at config root — handle separately
[[ -e "$CONFIG_DEST/starship.toml" ]] && rm -f "$CONFIG_DEST/starship.toml"

# ─── Stow ─────────────────────────────────────────────────────────────────────
msg "Running stow..."
cd "$ARCHER_REAL"
stow --target="$HOME/.config" --verbose=1 config
ok "Stow complete — ~/.config symlinked from $ARCHER_REAL/config"

# ─── Script permissions ───────────────────────────────────────────────────────
find "$CONFIG_DEST/hypr/scripts" -type f -exec chmod +x {} + 2>/dev/null || true
ok "Script permissions updated"

# ─── Output directories ───────────────────────────────────────────────────────
mkdir -p "$HOME/Pictures/Screenshots"
mkdir -p "$HOME/Videos/Screen Recordings"
ok "Output directories created"