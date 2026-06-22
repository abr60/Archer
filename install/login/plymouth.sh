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

# ─── Regenerate assets ────────────────────────────────────────────────────────
if [[ -f "$THEME_SRC/generate_assets.py" ]]; then
    msg "Regenerating PNG assets..."
    python3 "$THEME_SRC/generate_assets.py"
    sudo cp "$THEME_SRC"/*.png "$THEME_DEST/"
    ok "Assets regenerated"
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

# ─── Ensure splash in limine.conf ─────────────────────────────────────────────
LIMINE_CONF="/boot/limine/limine.conf"
if [[ -f "$LIMINE_CONF" ]]; then
    if ! grep -q 'splash' "$LIMINE_CONF"; then
        sudo sed -i 's/\(cmdline:.*\)rw/\1rw quiet splash/' "$LIMINE_CONF"
        ok "Added 'quiet splash' to limine.conf cmdline"
    else
        ok "splash already present in limine.conf"
    fi
else
    warn "limine.conf not found at $LIMINE_CONF — add 'quiet splash' to cmdline manually"
fi

# ─── Rebuild UKI ──────────────────────────────────────────────────────────────
msg "Rebuilding UKI (this may take a moment)..."
sudo mkinitcpio -p linux && ok "UKI rebuilt successfully" || warn "mkinitcpio failed — run manually"

ok "Plymouth setup complete — reboot to see the theme"