#!/usr/bin/env bash
# =============================================================================
# install/login/plymouth.sh — Install Archer Plymouth theme + mkinitcpio hooks
# Uses drop-in files (not sed on mkinitcpio.conf) — mirrors omarchy.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Plymouth Boot Splash"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
THEME_SRC="$ARCHER_DIR/default/plymouth/archer"
THEME_DEST="/usr/share/plymouth/themes/archer"

# ─── Install Plymouth ─────────────────────────────────────────────────────────
ensure_installed plymouth
ensure_installed ttf-liberation

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
    warn "plymouth.png not found at $WALLPAPER_SRC — copy manually to $THEME_DEST/plymouth.png"
fi

# ─── Regenerate assets (optional) ────────────────────────────────────────────
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

# ─── Set plymouth theme via plymouthd.conf ───────────────────────────────────
sudo mkdir -p /etc/plymouth
printf "[Daemon]\nTheme=archer\n" | sudo tee /etc/plymouth/plymouthd.conf >/dev/null
ok "Wrote /etc/plymouth/plymouthd.conf (Theme=archer)"

# ─── mkinitcpio drop-in: archer_hooks.conf ───────────────────────────────────
# Replaces HOOKS from /etc/mkinitcpio.conf with the correct boot stack:
# base udev plymouth keyboard autodetect microcode modconf kms keymap
# consolefont block encrypt filesystems fsck btrfs-overlayfs
# (uses busybox `encrypt`, not systemd sd-encrypt — matches omarchy)
sudo mkdir -p /etc/mkinitcpio.conf.d
sudo tee /etc/mkinitcpio.conf.d/archer_hooks.conf >/dev/null <<'HOOKS_EOF'
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck btrfs-overlayfs)

# Drop kms when NVIDIA owns every GPU (avoids pulling nouveau + 100MB GSP fw).
# Hybrid systems keep kms for iGPU early KMS at LUKS prompt.
if [[ " ${MODULES[*]:-} " == *" nvidia_drm "* ]]; then
  _archer_nvidia_gpu=0
  _archer_other_gpu=0
  for _archer_pci in "${OMARCHY_PCI_DEVICES_PATH:-/sys/bus/pci/devices}"/*; do
    if [[ ! -r $_archer_pci/class || ! -r $_archer_pci/vendor ]]; then
      _archer_other_gpu=1
      continue
    fi
    [[ $(<"$_archer_pci/class") == "0x03"* ]] || continue
    if [[ $(<"$_archer_pci/vendor") == "0x10de" ]]; then
      _archer_nvidia_gpu=1
    else
      _archer_other_gpu=1
    fi
  done
  if ((_archer_nvidia_gpu && !_archer_other_gpu)); then
    _archer_hooks=()
    for _archer_hook in "${HOOKS[@]}"; do
      [[ $_archer_hook == "kms" ]] || _archer_hooks+=("$_archer_hook")
    done
    HOOKS=("${_archer_hooks[@]}")
  fi
  unset _archer_nvidia_gpu _archer_other_gpu _archer_pci _archer_hooks _archer_hook
fi

# Bundle vconsole.conf so Plymouth uses the configured layout at LUKS prompt,
# but only for Latin layouts — bundling Hebrew/Cyrillic/Arabic would make the
# Latin passphrase untypeable and lock the user out.
if [[ -f /etc/vconsole.conf ]]; then
  case $(. /etc/vconsole.conf && echo "${XKBLAYOUT%%,*}") in
    af | am | ara | bd | bg | by | et | ge | gr | il | in | iq | ir | kg | kh | kz | la | lk | mk | mm | mn | mv | np | rs | ru | sy | th | tj | ua) ;;
    *) FILES+=(/etc/vconsole.conf) ;;
  esac
fi
HOOKS_EOF
ok "Wrote /etc/mkinitcpio.conf.d/archer_hooks.conf"

# Match omarchy: resume hook lives in its own drop-in so it can be
# toggled/overridden independently; omarchy_resume.conf uses HOOKS+=(resume).
sudo tee /etc/mkinitcpio.conf.d/archer_resume.conf >/dev/null <<'RESUME_EOF'
HOOKS+=(resume)
RESUME_EOF
ok "Wrote /etc/mkinitcpio.conf.d/archer_resume.conf (resume hook)"

# ─── Rebuild initramfs / UKIs ─────────────────────────────────────────────────
# limine-mkinitcpio builds UKIs and re-runs limine-entry-tool (preferred when
# limine-mkinitcpio-hook is installed). Fallback to mkinitcpio -P.
msg "Rebuilding initramfs / UKIs..."
if command -v limine-mkinitcpio &>/dev/null; then
    if sudo limine-mkinitcpio 2>&1 | tail -20; then
        ok "UKIs rebuilt via limine-mkinitcpio"
    else
        warn "limine-mkinitcpio failed — try manually: sudo limine-mkinitcpio"
    fi
elif sudo plymouth-set-default-theme -R archer 2>&1 | tail -10; then
    ok "Initramfs rebuilt via plymouth-set-default-theme -R"
else
    warn "plymouth-set-default-theme -R failed — trying mkinitcpio -P"
    sudo mkinitcpio -P 2>&1 | tail -20 && ok "initramfs rebuilt via mkinitcpio -P" || warn "mkinitcpio failed — run manually"
fi

ok "Plymouth setup complete — reboot to see the theme"
