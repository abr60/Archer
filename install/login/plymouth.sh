#!/usr/bin/env bash
# =============================================================================
# install/login/plymouth.sh — Install and configure Archer Plymouth theme
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Plymouth Boot Splash"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
THEME_SRC="$ARCHER_DIR/default/plymouth/archer"
THEME_DEST="/usr/share/plymouth/themes/archer"

# ─── Install Plymouth ─────────────────────────────────────────────────────────
ensure_installed plymouth

# ─── Validate source ──────────────────────────────────────────────────────────
if [[ ! -d "$THEME_SRC" ]]; then
    warn "Plymouth theme source not found at $THEME_SRC — skipping"
    exit 0
fi

# ─── Install theme files ──────────────────────────────────────────────────────
sudo mkdir -p "$THEME_DEST"
sudo cp "$THEME_SRC/archer.plymouth"    "$THEME_DEST/"
sudo cp "$THEME_SRC/archer.script"      "$THEME_DEST/"
sudo cp "$THEME_SRC/entry.png"          "$THEME_DEST/"
sudo cp "$THEME_SRC/lock.png"           "$THEME_DEST/"
sudo cp "$THEME_SRC/bullet.png"         "$THEME_DEST/"
sudo cp "$THEME_SRC/progress_box.png"   "$THEME_DEST/"
sudo cp "$THEME_SRC/progress_bar.png"   "$THEME_DEST/"
ok "Theme files installed to $THEME_DEST"

# ─── Install wallpaper ────────────────────────────────────────────────────────
WALLPAPER_SRC="$ARCHER_DIR/default/plymouth/plymouth.png"
if [[ -f "$WALLPAPER_SRC" ]]; then
    sudo cp "$WALLPAPER_SRC" "$THEME_DEST/plymouth.png"
    ok "Wallpaper installed"
else
    warn "plymouth.png not found at $WALLPAPER_SRC"
    warn "Copy your wallpaper manually to $THEME_DEST/plymouth.png"
fi

# ─── Regenerate assets (optional) ────────────────────────────────────────────
# By default uses pre-built PNGs from dotfiles.
# To regenerate: REGEN_ASSETS=true bash install/login/plymouth.sh
if [[ "${REGEN_ASSETS:-false}" == "true" ]]; then
    if command -v python3 &>/dev/null; then
        pip install pillow --break-system-packages -q
        python3 "$THEME_SRC/generate_assets.py"
        sudo cp "$THEME_SRC"/*.png "$THEME_DEST/"
        ok "Assets regenerated and installed"
    else
        warn "python3 not found — skipping asset regeneration, using pre-built PNGs"
    fi
fi

# ─── Set as default theme ─────────────────────────────────────────────────────
sudo plymouth-set-default-theme archer
ok "Plymouth default theme set to archer"

# ─── Ensure plymouth hook is in mkinitcpio ────────────────────────────────────
MKINITCPIO="/etc/mkinitcpio.conf"
if ! grep -q 'plymouth' "$MKINITCPIO"; then
    sudo sed -i 's/^\(HOOKS=([^)]*udev\)/\1 plymouth/' "$MKINITCPIO"
    ok "Plymouth hook added to mkinitcpio.conf"
else
    ok "Plymouth hook already present in mkinitcpio.conf"
fi

# ─── Remove default Arch splash BMP ──────────────────────────────────────────
PRESET="/etc/mkinitcpio.d/linux.preset"
if [[ -f "$PRESET" ]]; then
    if grep -q 'splash-arch.bmp' "$PRESET"; then
        sudo sed -i 's/default_options="--splash \/usr\/share\/systemd\/bootctl\/splash-arch.bmp"/default_options=""/' "$PRESET"
        ok "Arch splash BMP removed from mkinitcpio preset"
    else
        ok "Arch splash BMP already removed"
    fi
else
    warn "mkinitcpio preset not found at $PRESET"
fi

# ─── Ensure splash in limine.conf ─────────────────────────────────────────────
# Note: limine.conf must already exist at /boot/limine/limine.conf
# Run refresh-limine before this script if it doesn't exist yet
LIMINE_CONF="/boot/limine/limine.conf"
if [[ -f "$LIMINE_CONF" ]]; then
    if ! grep -q 'splash' "$LIMINE_CONF"; then
        sudo sed -i '/cmdline:/ s/$/ quiet splash/' "$LIMINE_CONF"
        ok "Added 'quiet splash' to limine.conf cmdline"
    else
        ok "splash already present in limine.conf"
    fi
else
    warn "limine.conf not found at $LIMINE_CONF"
    warn "Run refresh-limine first, then re-run this script to add splash to cmdline"
fi

# ─── Rebuild UKI ──────────────────────────────────────────────────────────────
msg "Rebuilding UKI (this may take a moment)..."
sudo mkinitcpio -p linux && ok "UKI rebuilt successfully" || warn "mkinitcpio failed — run manually"

ok "Plymouth setup complete — reboot to see the theme"