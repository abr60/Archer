#!/usr/bin/env bash
# =============================================================================
# login/plymouth.sh — Install and configure Plymouth boot splash
# Uses the Archer/omarchy Plymouth theme from default/plymouth/
# Configures plymouth-login PAM for graphical user password prompt
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../lib/backup.sh"

section "Plymouth Boot Splash"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
PLYMOUTH_SRC="$ARCHER_DIR/default/plymouth"
PLYMOUTH_THEME_DEST="/usr/share/plymouth/themes/archer"

load_backup_session

# ─── Install Plymouth ─────────────────────────────────────────────────────────
ensure_installed plymouth

# ─── Install theme files ──────────────────────────────────────────────────────
if [[ ! -d "$PLYMOUTH_SRC" ]]; then
    warn "Plymouth theme source not found at $PLYMOUTH_SRC — skipping"
    exit 0
fi

sudo mkdir -p "$PLYMOUTH_THEME_DEST"
sudo cp "$PLYMOUTH_SRC"/*.png "$PLYMOUTH_THEME_DEST/" 2>/dev/null || true
sudo cp "$PLYMOUTH_SRC"/*.script "$PLYMOUTH_THEME_DEST/" 2>/dev/null || true

# Install .plymouth manifest — rename from omarchy to archer
if [[ -f "$PLYMOUTH_SRC/omarchy.plymouth" ]]; then
    sudo cp "$PLYMOUTH_SRC/omarchy.plymouth" "$PLYMOUTH_THEME_DEST/archer.plymouth"
    # Fix internal paths to point to archer theme dir
    sudo sed -i \
        's|/usr/share/plymouth/themes/omarchy|/usr/share/plymouth/themes/archer|g' \
        "$PLYMOUTH_THEME_DEST/archer.plymouth"
    ok "Plymouth theme installed to $PLYMOUTH_THEME_DEST"
else
    warn "omarchy.plymouth manifest not found — skipping theme install"
    exit 0
fi

# ─── Set as default theme ─────────────────────────────────────────────────────
sudo plymouth-set-default-theme archer
ok "Plymouth theme set to archer"

# ─── Configure mkinitcpio ─────────────────────────────────────────────────────
MKINITCPIO_CONF="/etc/mkinitcpio.conf"
backup_file "$MKINITCPIO_CONF"

if ! grep -q 'plymouth' "$MKINITCPIO_CONF"; then
    sudo sed -i 's/^HOOKS=(\(.*\)udev\(.*\))/HOOKS=(\1udev plymouth\2)/' "$MKINITCPIO_CONF"
    ok "Plymouth hook added to mkinitcpio.conf"
else
    ok "Plymouth already in mkinitcpio.conf — skipping"
fi

# ─── Rebuild initramfs ────────────────────────────────────────────────────────
msg "Rebuilding initramfs (this may take a moment)..."
sudo mkinitcpio -P && ok "Initramfs rebuilt" || warn "mkinitcpio failed — run manually"

# ─── PAM login integration ────────────────────────────────────────────────────
# Configures plymouth-login so a graphical password prompt appears
# before SDDM starts (no disk encryption required)
PAM_LOGIN="/etc/pam.d/login"
backup_file "$PAM_LOGIN"

if ! grep -q "pam_plymouth" "$PAM_LOGIN" 2>/dev/null; then
    if [[ -f /usr/lib/security/pam_plymouth.so ]]; then
        sudo sed -i '/auth.*include.*system-local-login/a auth       optional     pam_plymouth.so' "$PAM_LOGIN"
        sudo sed -i '/session.*include.*system-local-login/a session    optional     pam_plymouth.so' "$PAM_LOGIN"
        ok "Plymouth PAM login integration configured"
    else
        warn "pam_plymouth.so not found — skipping PAM integration"
        warn "Install plymouth with PAM support for graphical password prompt"
    fi
else
    ok "Plymouth PAM already configured — skipping"
fi

# ─── Kernel cmdline ───────────────────────────────────────────────────────────
warn "Remember to add 'splash' and 'quiet' to your kernel parameters"
warn "in your bootloader config for Plymouth to show on boot"

ok "Plymouth setup complete"
