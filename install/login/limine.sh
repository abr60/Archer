#!/usr/bin/env bash
# archer:summary=Deploy Limine config with auto-detected LUKS PARTUUID

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
TEMPLATE="$ARCHER_DIR/default/limine/limine.conf"
DEST="/boot/limine/limine.conf"

# Auto-detect LUKS partition PARTUUID
LUKS_DEV=$(sudo dmsetup deps -o devname root 2>/dev/null | grep -oP '\(.*?\)' | tr -d '()' | head -1)
if [[ -z "$LUKS_DEV" ]]; then
    # Fallback — find encrypted partition manually
    LUKS_DEV=$(lsblk -rno NAME,TYPE | awk '$2=="part"' | while read name _; do
        sudo cryptsetup isLuks "/dev/$name" 2>/dev/null && echo "$name" && break
    done)
fi

PARTUUID=$(lsblk -rno PARTUUID "/dev/$LUKS_DEV" 2>/dev/null)

if [[ -z "$PARTUUID" ]]; then
    echo "ERROR: Could not detect LUKS PARTUUID — set it manually in $DEST"
    exit 1
fi

echo "Detected LUKS PARTUUID: $PARTUUID"

# Deploy template with PARTUUID substituted
if [[ ! -f "$TEMPLATE" ]]; then
    echo "ERROR: Template not found at $TEMPLATE"
    exit 1
fi
sudo cp "$TEMPLATE" "$DEST"
sudo sed -i "s/%%LUKS_PARTUUID%%/$PARTUUID/g" "$DEST"

echo "Limine config deployed to $DEST"

LIMINE_PNG="$ARCHER_DIR/default/limine/limine.png"
if [[ -f "$LIMINE_PNG" ]]; then
    sudo cp "$LIMINE_PNG" /boot/limine/limine.png
    echo "Limine background image deployed to /boot/limine/limine.png"
else
    echo "WARNING: limine.png not found at $LIMINE_PNG — copy manually"
fi