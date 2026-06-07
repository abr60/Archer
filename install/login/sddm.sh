#!/usr/bin/env bash
# =============================================================================
# login/sddm.sh — Set up SDDM display manager with autologin
# Replaces greetd. Uses Wayland session via UWSM.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/backup.sh"

section "SDDM Display Manager"

load_backup_session

# ─── Install SDDM if missing ──────────────────────────────────────────────────
ensure_installed sddm

# ─── Disable greetd if active ─────────────────────────────────────────────────
if systemctl is-enabled greetd.service &>/dev/null; then
    sudo systemctl disable greetd.service
    ok "greetd disabled"
fi

# ─── Wayland session config ───────────────────────────────────────────────────
sudo mkdir -p /etc/sddm.conf.d

# Wayland compositor config
backup_file "/etc/sddm.conf.d/10-wayland.conf"
sudo tee /etc/sddm.conf.d/10-wayland.conf > /dev/null << 'EOF'
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=uwsm start hyprland
EOF
ok "SDDM Wayland config written"

# ─── Autologin ────────────────────────────────────────────────────────────────
if [[ ! -f /etc/sddm.conf.d/autologin.conf ]]; then
    sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null << EOF
[Autologin]
User=$USER
Session=hyprland-uwsm

[Theme]
Current=
EOF
    ok "Autologin configured for $USER"
else
    ok "autologin.conf already exists — skipping"
fi

# ─── Enable SDDM ──────────────────────────────────────────────────────────────
sudo systemctl enable sddm.service
ok "SDDM enabled"

warn "SDDM will start on next reboot"
