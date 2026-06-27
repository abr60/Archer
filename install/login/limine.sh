#!/usr/bin/env bash
# =============================================================================
# extras/limine.sh — Deploy Limine config with auto-detected LUKS PARTUUID
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Limine Bootloader Config"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
TEMPLATE="$ARCHER_DIR/default/limine/limine.conf"
DEST="/boot/limine/limine.conf"

# ─── Validate template ────────────────────────────────────────────────────────
if [[ ! -f "$TEMPLATE" ]]; then
    err "Template not found at $TEMPLATE"
    exit 1
fi

# ─── Auto-detect LUKS partition PARTUUID ─────────────────────────────────────
msg "Detecting LUKS partition PARTUUID..."

LUKS_DEV=$(sudo dmsetup deps -o devname root 2>/dev/null | grep -oP '\(.*?\)' | tr -d '()' | head -1)

if [[ -z "$LUKS_DEV" ]]; then
    warn "dmsetup detection failed — scanning lsblk for LUKS partition..."
    LUKS_DEV=$(lsblk -rno NAME,TYPE | awk '$2=="part"' | while read -r name _; do
        sudo cryptsetup isLuks "/dev/$name" 2>/dev/null && echo "$name" && break
    done)
fi

if [[ -z "$LUKS_DEV" ]]; then
    err "Could not detect LUKS device — set PARTUUID manually in $DEST"
    exit 1
fi

PARTUUID=$(lsblk -rno PARTUUID "/dev/$LUKS_DEV" 2>/dev/null)

if [[ -z "$PARTUUID" ]]; then
    err "Could not detect LUKS PARTUUID — set it manually in $DEST"
    exit 1
fi

ok "Detected LUKS device  : /dev/$LUKS_DEV"
ok "Detected PARTUUID     : $PARTUUID"

# ─── Deploy config ────────────────────────────────────────────────────────────
sudo mkdir -p /boot/limine
sudo cp "$TEMPLATE" "$DEST"
sudo sed -i "s/%%LUKS_PARTUUID%%/$PARTUUID/g" "$DEST"
ok "Limine config deployed to $DEST"

# ─── Deploy background image ──────────────────────────────────────────────────
LIMINE_PNG="$ARCHER_DIR/default/limine/limine.png"
if [[ -f "$LIMINE_PNG" ]]; then
    sudo cp "$LIMINE_PNG" /boot/limine/limine.png
    ok "Limine background image deployed to /boot/limine/limine.png"
else
    warn "limine.png not found at $LIMINE_PNG — copy manually"
fi

ok "Limine setup complete"