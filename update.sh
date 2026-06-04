#!/usr/bin/env bash
# =============================================================================
# Archer - Update Script
# Pulls latest changes from the repo and re-applies everything safely.
# Usage: bash ~/Archer/update.sh
# =============================================================================

set -euo pipefail

DOTS_DIR="$HOME/Archer"
INSTALL_DIR="$DOTS_DIR/install"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

msg()  { echo -e "${BLUE}==>${NC} $1"; }
ok()   { echo -e "${GREEN} ✓${NC} $1"; }
warn() { echo -e "${YELLOW} !${NC} $1"; }
die()  { echo -e "${RED}ERR${NC} $1"; exit 1; }

# ==========================================
# 1. DEPENDENCY CHECK
# ==========================================
if ! command -v gum &>/dev/null; then
    msg "Installing gum..."
    sudo pacman -S --needed --noconfirm gum
fi

# ==========================================
# 2. SHOW HEADER
# ==========================================
clear
LOGO_FILE="$DOTS_DIR/install/lib/logo.txt"
if [[ -f "$LOGO_FILE" ]]; then
    cat "$LOGO_FILE"
    echo ""
fi

gum style \
    --foreground 117 \
    --border-foreground 117 \
    --border rounded \
    --align center \
    --width 50 \
    --padding "0 1" \
    "ARCHER UPDATE"

echo ""

# ==========================================
# 3. CHECK FOR CHANGES BEFORE PULLING
# ==========================================
msg "Checking for updates..."
cd "$DOTS_DIR"

# Fetch without merging first
git fetch origin main 2>/dev/null || git fetch origin master 2>/dev/null || {
    die "Could not reach remote. Check your internet connection."
}

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "unknown")

if [[ "$LOCAL" == "$REMOTE" ]]; then
    ok "Already up to date. Nothing to do."
    exit 0
fi

# Show what changed
echo ""
msg "Changes incoming:"
git log HEAD..@{u} --oneline --no-decorate 2>/dev/null || true
echo ""

gum confirm "Apply these updates?" || { msg "Update cancelled."; exit 0; }

# ==========================================
# 4. PULL
# ==========================================
echo ""
msg "Pulling latest changes..."
git pull --ff-only || die "Git pull failed. You may have local conflicts."
ok "Repo updated"

# ==========================================
# 5. RE-APPLY
# ==========================================
START_TIME=$SECONDS

run_step() {
    local script="$1"
    local label="$2"

    echo ""
    msg "$label"

    if [[ ! -f "$INSTALL_DIR/$script" ]]; then
        warn "$script not found — skipping"
        return
    fi

    chmod +x "$INSTALL_DIR/$script"
    bash "$INSTALL_DIR/$script" || warn "$label had errors — continuing"
    ok "$label done"
}

export INSTALL_MODE="complete"

run_step "packages-pacman"  "Syncing pacman packages"
run_step "packages-aur"     "Syncing AUR packages"
run_step "fonts"            "Syncing fonts"
run_step "services"         "Syncing services"

# Re-run stow to pick up any new config entries
echo ""
msg "Re-applying config symlinks..."
cd "$HOME/.local/share/Archer"
stow --restow --target="$HOME/.config" config 2>/dev/null \
    && ok "Config symlinks refreshed" \
    || warn "Stow had conflicts — check manually"

# ==========================================
# 6. RELOAD
# ==========================================
run_step "reload" "Reloading UI"

# ==========================================
# 7. DONE
# ==========================================
DURATION=$(( SECONDS - START_TIME ))
echo ""
gum style \
    --foreground 82 --border-foreground 82 --border rounded \
    --align center --width 50 --padding "1 2" \
    "✓ UPDATE COMPLETE" \
    "Finished in ${DURATION}s"
