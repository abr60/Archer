#!/usr/bin/env bash
# =============================================================================
# login/sddm.sh — Install SDDM with Archer's japanese_aesthetic theme
# and autologin into Hyprland via uwsm
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "SDDM Display Manager"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
THEME_SRC="$ARCHER_DIR/default/sddm"
THEME_DEST="/usr/share/sddm/themes/sddm-astronaut-theme"

# ─── Install SDDM ─────────────────────────────────────────────────────────────
ensure_installed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg

# ─── Install theme files ──────────────────────────────────────────────────────
if [[ ! -d "$THEME_SRC" ]]; then
    warn "SDDM theme source not found at $THEME_SRC — skipping theme install"
else
    sudo mkdir -p "$THEME_DEST"/{Components,Assets,Fonts,Backgrounds,Themes}

    sudo cp "$THEME_SRC/Main.qml"           "$THEME_DEST/"
    sudo cp "$THEME_SRC/metadata.desktop"   "$THEME_DEST/"
    sudo cp "$THEME_SRC/Components/"*       "$THEME_DEST/Components/"
    sudo cp "$THEME_SRC/Assets/"*           "$THEME_DEST/Assets/"
    sudo cp "$THEME_SRC/Fonts/"*            "$THEME_DEST/Fonts/"
    sudo cp "$THEME_SRC/Backgrounds/"*      "$THEME_DEST/Backgrounds/"
    sudo cp "$THEME_SRC/Themes/"*           "$THEME_DEST/Themes/"

    ok "Theme files installed to $THEME_DEST"
fi

# ─── Install Electroharmonix font system-wide ─────────────────────────────────
if [[ -f "$THEME_SRC/Fonts/Electroharmonix.otf" ]]; then
    sudo cp "$THEME_SRC/Fonts/Electroharmonix.otf" /usr/share/fonts/
    sudo fc-cache -f
    ok "Electroharmonix font installed"
fi

# ─── SDDM config — Wayland + theme ───────────────────────────────────────────
sudo mkdir -p /etc/sddm.conf.d

sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null << 'EOF'
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=uwsm start hyprland
EOF
ok "Wayland config written"

sudo tee /etc/sddm.conf.d/20-theme.conf > /dev/null << 'EOF'
[Theme]
Current=sddm-astronaut-theme
ConfigFile=/usr/share/sddm/themes/sddm-astronaut-theme/Themes/japanese_aesthetic.conf
EOF
ok "Theme config written"

sudo tee /etc/sddm.conf.d/30-autologin.conf > /dev/null << EOF
[Autologin]
User=$USER
Session=hyprland-uwsm
EOF
ok "Autologin configured for $USER"

# ─── Enable SDDM ──────────────────────────────────────────────────────────────
sudo systemctl enable sddm.service
ok "SDDM enabled — will start on next reboot"