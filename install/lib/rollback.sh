#!/usr/bin/env bash
# =============================================================================
# lib/rollback.sh — Restore files from an Archer backup session
# Usage: bash ~/.local/share/archer-backups/<session>/rollback.sh
#    or: bash ~/Archer/install/lib/rollback.sh [backup-dir]
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "${GREEN} ✓${NC} $1"; }
warn() { echo -e "${YELLOW} !${NC} $1"; }
err()  { echo -e "${RED} ✗${NC} $1"; }
msg()  { echo -e "${BLUE}==>${NC} $1"; }

BACKUP_ROOT="$HOME/.local/share/archer-backups"

if [[ -n "${1:-}" ]]; then
    BACKUP_DIR="$1"
else
    [[ ! -d "$BACKUP_ROOT" ]] && { err "No backups found at $BACKUP_ROOT"; exit 1; }
    BACKUP_DIR=$(ls -1dt "$BACKUP_ROOT"/backup_* 2>/dev/null | head -n1)
    [[ -z "$BACKUP_DIR" ]] && { err "No backup sessions found"; exit 1; }
    msg "Using most recent backup: $(basename "$BACKUP_DIR")"
fi

RESTORE_FILE="$BACKUP_DIR/RESTORE.txt"
[[ ! -f "$RESTORE_FILE" ]] && { err "RESTORE.txt not found in $BACKUP_DIR"; exit 1; }

echo ""
grep -E '^(Created|Session|Machine)' "$RESTORE_FILE" | while read -r line; do msg "$line"; done
echo ""

TOTAL=$(grep -c '^ *Restore:' "$RESTORE_FILE" || true)
[[ "$TOTAL" -eq 0 ]] && { warn "Backup is empty — nothing to restore"; exit 0; }

msg "Files to restore: $TOTAL"
grep '^- ' "$RESTORE_FILE" | head -10 | while read -r line; do echo "  $line"; done
echo ""

NEEDS_SUDO=false
grep -q '^ *Restore:.*sudo' "$RESTORE_FILE" && NEEDS_SUDO=true

if command -v gum &>/dev/null; then
    gum confirm "Restore $TOTAL files from $(basename "$BACKUP_DIR")?" || { warn "Rollback cancelled"; exit 0; }
else
    read -rp "Restore $TOTAL files? This overwrites current state. [y/N] " reply
    [[ "$reply" =~ ^[Yy]$ ]] || { warn "Rollback cancelled"; exit 0; }
fi

$NEEDS_SUDO && { sudo -v || { err "Sudo authentication failed"; exit 1; }; }

msg "Starting rollback..."
echo ""

RESTORED=0
FAILED=0
NEEDS_MKINITCPIO=false

while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*Restore:[[:space:]](.+)$ ]]; then
        cmd="${BASH_REMATCH[1]}"
        msg "Restoring: $cmd"
        if eval "$cmd"; then
            ok "Done [$((++RESTORED))/$TOTAL]"
            [[ "$cmd" =~ /etc/mkinitcpio\.conf ]] && NEEDS_MKINITCPIO=true
        else
            err "Failed: $cmd"
            (( FAILED++ )) || true
        fi
        echo ""
    fi
done < "$RESTORE_FILE"

if $NEEDS_MKINITCPIO; then
    msg "Rebuilding initramfs..."
    sudo mkinitcpio -P && ok "Initramfs rebuilt" || err "Run 'sudo mkinitcpio -P' manually"
fi

echo ""
if [[ "$FAILED" -eq 0 ]]; then
    ok "Rollback complete — $RESTORED/$TOTAL files restored"
else
    warn "Rollback finished with $FAILED failure(s) — $RESTORED/$TOTAL restored"
fi
msg "Original backup: $BACKUP_DIR"
