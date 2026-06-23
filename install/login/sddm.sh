#!/usr/bin/env bash
# =============================================================================
# login/sddm.sh — Install SDDM with autologin into Hyprland via uwsm
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "SDDM Display Manager"

# ─── Install SDDM ─────────────────────────────────────────────────────────────
ensure_installed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg

# ─── Wayland config ───────────────────────────────────────────────────────────
sudo mkdir -p /etc/sddm.conf.d

sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null << 'EOF'
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=uwsm start hyprland
EOF
ok "Wayland config written"

# ─── Autologin ────────────────────────────────────────────────────────────────
sudo tee /etc/sddm.conf.d/20-autologin.conf > /dev/null << EOF
[Autologin]
User=$USER
Session=hyprland-uwsm
EOF
ok "Autologin configured for $USER"

# ─── Enable SDDM ──────────────────────────────────────────────────────────────
sudo systemctl enable sddm.service
ok "SDDM enabled — will start on next reboot"