#!/usr/bin/env bash
# =============================================================================
# hardware/unmount-fuse.sh — Install FUSE unmount hook for sleep/resume
# Prevents FUSE filesystem issues on suspend/resume
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Unmount FUSE on Sleep"

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
SRC="$ARCHER_DIR/default/systemd/system-sleep/unmount-fuse"
DEST="/usr/lib/systemd/system-sleep/unmount-fuse"

if [[ -f "$DEST" ]]; then
    ok "unmount-fuse hook already installed — skipping"
    exit 0
fi

if [[ ! -f "$SRC" ]]; then
    warn "unmount-fuse not found at $SRC — skipping"
    exit 0
fi

sudo mkdir -p /usr/lib/systemd/system-sleep
sudo install -m 0755 -o root -g root "$SRC" "$DEST"

ok "unmount-fuse sleep hook installed"
