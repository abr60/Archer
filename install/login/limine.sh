#!/usr/bin/env bash
# =============================================================================
# install/login/limine.sh — Deploy Limine bootloader (omarchy mechanism)
# Writes /etc/kernel/cmdline, header to /boot/limine.conf, drop-ins,
# then registers EFI entry and generates boot entries via limine-entry-tool.
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Limine Bootloader Config"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
TEMPLATE="$ARCHER_DIR/default/limine/limine.conf"
DEST="/boot/limine.conf"

# ─── Ensure packages ──────────────────────────────────────────────────────────
# limine-mkinitcpio-hook provides limine-install, limine-entry-tool,
# limine-mkinitcpio, btrfs-overlayfs hook, UKI support and pacman hooks.
if ! is_installed limine-mkinitcpio-hook 2>/dev/null; then
    # limine is in extra, limine-mkinitcpio-hook is AUR/chaotic
    ensure_installed limine
    msg "Installing limine-mkinitcpio-hook (AUR)..."
    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm limine-mkinitcpio-hook 2>&1 | tail -5 || warn "yay install failed — run manually: yay -S limine-mkinitcpio-hook"
    else
        warn "yay not found — install limine-mkinitcpio-hook manually: yay -S limine-mkinitcpio-hook"
    fi
else
    ok "limine-mkinitcpio-hook already installed"
fi

# Optional but recommended for snapshot boot entries
if ! is_installed snapper 2>/dev/null; then
    ensure_installed snapper
fi
if ! pacman -Q limine-snapper-sync &>/dev/null 2>/dev/null; then
    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm limine-snapper-sync 2>&1 | tail -3 || warn "limine-snapper-sync not installed (optional)"
    fi
fi

# ─── Validate template ────────────────────────────────────────────────────────
if [[ ! -f "$TEMPLATE" ]]; then
    err "Template not found at $TEMPLATE"
    exit 1
fi

# ─── Detect LUKS and write /etc/kernel/cmdline ───────────────────────────────
# limine-entry-tool reads /etc/kernel/cmdline to build boot entries.
msg "Detecting root filesystem and LUKS status..."

CMDLINE_FILE="/etc/kernel/cmdline"
# Primary path is btrfs + LUKS (matches omarchy manual install). Fallback handles plain installs.
BASE_CMDLINE_BTRFS="zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs"
BASE_CMDLINE_PLAIN="zswap.enabled=0 rw"

LUKS_DEV=""
if sudo dmsetup deps -o devname root 2>/dev/null | grep -q .; then
    LUKS_DEV=$(sudo dmsetup deps -o devname root 2>/dev/null | grep -oP '\(.*?\)' | tr -d '()' | head -1 || true)
fi
if [[ -z "$LUKS_DEV" ]]; then
    LUKS_DEV=$(lsblk -rno NAME,TYPE 2>/dev/null | awk '$2=="part"' | while read -r name _; do
        sudo cryptsetup isLuks "/dev/$name" 2>/dev/null && echo "$name" && break
    done || true)
fi

sudo mkdir -p "$(dirname "$CMDLINE_FILE")"

if [[ -n "$LUKS_DEV" ]]; then
    PARTUUID=$(lsblk -rno PARTUUID "/dev/$LUKS_DEV" 2>/dev/null || true)
    if [[ -n "$PARTUUID" ]]; then
        ok "Detected LUKS device  : /dev/$LUKS_DEV"
        ok "Detected PARTUUID     : $PARTUUID"
        echo "cryptdevice=PARTUUID=$PARTUUID:root root=/dev/mapper/root $BASE_CMDLINE_BTRFS" | sudo tee "$CMDLINE_FILE" >/dev/null
    else
        warn "LUKS device /dev/$LUKS_DEV has no PARTUUID — writing btrfs cmdline without cryptdevice"
        echo "$BASE_CMDLINE_BTRFS" | sudo tee "$CMDLINE_FILE" >/dev/null
    fi
else
    # Fallback: plain install (no LUKS) — detect fstype to avoid wrong rootflags on ext4
    msg "No LUKS device detected — plain install"
    ROOT_SRC=$(findmnt -no SOURCE / 2>/dev/null | sed 's/\[.*\]//')
    ROOT_FSTYPE=$(findmnt -no FSTYPE / 2>/dev/null || echo "btrfs")
    ROOT_UUID=$(lsblk -rno UUID "$ROOT_SRC" 2>/dev/null || true)
    ROOT_SPEC="root=${ROOT_UUID:+UUID=$ROOT_UUID}"
    [[ -z "$ROOT_UUID" ]] && ROOT_SPEC="root=$ROOT_SRC"
    if [[ "$ROOT_FSTYPE" == "btrfs" ]]; then
        echo "$ROOT_SPEC $BASE_CMDLINE_BTRFS" | sudo tee "$CMDLINE_FILE" >/dev/null
    else
        echo "$ROOT_SPEC $BASE_CMDLINE_PLAIN" | sudo tee "$CMDLINE_FILE" >/dev/null
    fi
fi
ok "Wrote $CMDLINE_FILE"

# ─── Deploy header ────────────────────────────────────────────────────────────
sudo cp "$TEMPLATE" "$DEST"
ok "Limine header deployed to $DEST (flat, not /boot/limine/)"

# ─── Write limine-entry-tool drop-ins ───────────────────────────────────────
# Mirrors omarchy's /etc/limine-entry-tool.d/omarchy-{defaults,uki}.conf
sudo mkdir -p /etc/limine-entry-tool.d

sudo tee /etc/limine-entry-tool.d/archer-defaults.conf >/dev/null <<'EOF'
TARGET_OS_NAME="Archer"

KERNEL_CMDLINE[default]+=" quiet splash loglevel=0 systemd.show_status=false rd.udev.log_level=0 vt.global_cursor_default=0"

# Kernel 7.1+ unpacks initramfs asynchronously which races /init — unpack synchronously.
KERNEL_CMDLINE[default]+=" initramfs_async=0"

CUSTOM_UKI_NAME="archer"
ENABLE_LIMINE_FALLBACK=yes
FIND_BOOTLOADERS=yes
BOOT_ORDER="*, *fallback, Snapshots"
MAX_SNAPSHOT_ENTRIES=6
SNAPSHOT_FORMAT_CHOICE=5
EOF
ok "Wrote /etc/limine-entry-tool.d/archer-defaults.conf"

sudo tee /etc/limine-entry-tool.d/archer-uki.conf >/dev/null <<'EOF'
ENABLE_UKI=yes
EOF
ok "Wrote /etc/limine-entry-tool.d/archer-uki.conf"

# ─── Deploy background image ──────────────────────────────────────────────────
LIMINE_PNG="$ARCHER_DIR/default/limine/limine.png"
if [[ -f "$LIMINE_PNG" ]]; then
    sudo cp "$LIMINE_PNG" /boot/limine.png
    ok "Limine background deployed to /boot/limine.png"
else
    warn "limine.png not found at $LIMINE_PNG — copy manually to /boot/limine.png if needed"
fi

# ─── Register EFI entry and generate boot entries ─────────────────────────────
if command -v limine-install &>/dev/null; then
    msg "Registering Limine EFI entry..."
    sudo limine-install 2>&1 | tail -5 || warn "limine-install failed — run manually: sudo limine-install"
    # Ensure fallback BOOTX64.EFI exists
    sudo limine-install --fallback 2>&1 | tail -3 || true
else
    warn "limine-install not found — skipping EFI registration"
fi

if command -v limine-entry-tool &>/dev/null; then
    msg "Generating boot entries via limine-entry-tool..."
    sudo limine-entry-tool 2>&1 | tail -10 || warn "limine-entry-tool failed"
    ok "Boot entries generated"
else
    warn "limine-entry-tool not found — boot entries not generated"
fi

ok "Limine setup complete — UKIs will be built by plymouth step (limine-mkinitcpio)"
