#!/usr/bin/env bash
# =============================================================================
# Archer - Update Script
# Remote-first: always overwrites local with remote state.
# Usage: bash ~/Archer/update.sh
# =============================================================================

set -uo pipefail

DOTS_DIR="$HOME/Archer"
INSTALL_DIR="$DOTS_DIR/install"
WALLPAPERS_DIR="$HOME/Wallpapers"
REPORT_DIR="$HOME/.local/state/Archer"
REPORT_FILE="$REPORT_DIR/update-report.txt"

# --- Colors ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

msg()     { echo -e "${BLUE}==>${NC} $1"; }
ok()      { echo -e "${GREEN} ✓${NC} $1"; }
warn()    { echo -e "${YELLOW} !${NC} $1"; }
err()     { echo -e "${RED} ✗${NC} $1"; }
section() { echo -e "\n${BOLD}${CYAN}--- $1 ---${NC}"; }
die()     { echo -e "${RED}ERR${NC} $1"; echo " FAILED: $1" >> "$REPORT_FILE"; exit 1; }

mkdir -p "$REPORT_DIR"
START_TIME=$SECONDS

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
# 3. FETCH & CHECK
# ==========================================
msg "Fetching remote changes..."
cd "$DOTS_DIR"

git fetch origin 2>/dev/null || die "Could not reach remote — check your network."

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/HEAD 2>/dev/null || git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
LOCAL_SHORT="${LOCAL:0:7}"
REMOTE_SHORT="${REMOTE:0:7}"

# --- Write report header ---
{
    echo "=============================================="
    echo " ARCHER UPDATE REPORT"
    echo "=============================================="
    echo " Date       : $(date '+%Y-%m-%d %H:%M:%S')"
    echo " Hostname   : $(cat /etc/hostname)"
    echo " Kernel     : $(uname -r)"
    echo " Local      : $LOCAL_SHORT"
    echo " Remote     : $REMOTE_SHORT"
    echo "=============================================="
} > "$REPORT_FILE"

# --- Already up to date? ---
if [[ "$LOCAL" == "$REMOTE" ]]; then
    ok "Already up to date ($LOCAL_SHORT). Nothing to do."
    {
        echo ""
        echo " Status : Already up to date — no changes applied."
        echo "=============================================="
    } >> "$REPORT_FILE"
    exit 0
fi

# ==========================================
# 4. SHOW DIFF SUMMARY
# ==========================================
section "Incoming Changes (remote vs local)"
echo ""
git log HEAD..origin/HEAD --oneline --no-decorate 2>/dev/null || \
git log HEAD..origin/main --oneline --no-decorate 2>/dev/null || \
git log HEAD..origin/master --oneline --no-decorate 2>/dev/null || true

echo ""
CHANGED_FILES=$(git diff --name-only HEAD...origin/HEAD 2>/dev/null | head -20 || true)
if [[ -n "$CHANGED_FILES" ]]; then
    msg "Files that will change:"
    echo "$CHANGED_FILES" | while read -r f; do
        echo -e "  ${CYAN}~${NC} $f"
    done
fi

# --- Save diff to report ---
{
    echo ""
    echo "=============================================="
    echo " INCOMING CHANGES"
    echo "=============================================="
    git log HEAD..origin/HEAD --oneline --no-decorate 2>/dev/null || true
    echo ""
    echo " Files changed:"
    git diff --name-only HEAD...origin/HEAD 2>/dev/null | sed 's/^/   ~ /' || true
} >> "$REPORT_FILE"

# ==========================================
# 5. RESET & PULL (remote-first, no conflicts)
# ==========================================
echo ""
msg "Applying remote state (overwriting local)..."

# Save old commit before overwriting
OLD_COMMIT="$LOCAL"

git reset --hard "$REMOTE" || die "git reset --hard failed."
ok "Local reset to remote state ($LOCAL_SHORT → $REMOTE_SHORT)"

{
    echo ""
    echo "=============================================="
    echo " RESET"
    echo "=============================================="
    echo " From : $OLD_COMMIT"
    echo " To   : $REMOTE"
    echo " Status : Success"
} >> "$REPORT_FILE"

# ==========================================
# 6. RE-APPLY INSTALL SCRIPTS
# ==========================================
run_step() {
    local script="$1"
    local label="$2"

    echo ""
    msg "$label"

    if [[ ! -f "$INSTALL_DIR/$script" ]]; then
        warn "$script not found — skipping"
        echo " SKIPPED: $label (script not found)" >> "$REPORT_FILE"
        return
    fi

    chmod +x "$INSTALL_DIR/$script"

    if bash "$INSTALL_DIR/$script"; then
        ok "$label done"
        echo " OK: $label" >> "$REPORT_FILE"
    else
        warn "$label had errors — continuing"
        echo " WARN: $label had errors" >> "$REPORT_FILE"
    fi
}

export INSTALL_MODE="complete"

section "Re-applying Scripts"
run_step "packages-pacman"  "Syncing pacman packages"
run_step "packages-aur"     "Syncing AUR packages"
run_step "fonts"            "Syncing fonts"
run_step "services"         "Syncing services"

# ==========================================
# 7. STOW — RE-APPLY CONFIG SYMLINKS
# ==========================================
section "Re-applying Config Symlinks"
msg "Running stow..."

STOW_ERRORS=()
STOW_OUTPUT=$(stow --restow --target="$HOME/.config" config 2>&1) || true

if echo "$STOW_OUTPUT" | grep -qi "conflict\|error\|cannot"; then
    # Extract conflicting files clearly
    while IFS= read -r line; do
        if echo "$line" | grep -qi "conflict\|error\|cannot"; then
            CONFLICTING_FILE=$(echo "$line" | grep -oP '(?<=existing target is )[^ ]+' || echo "$line")
            warn "Stow conflict: $CONFLICTING_FILE"
            STOW_ERRORS+=("$CONFLICTING_FILE")
        fi
    done <<< "$STOW_OUTPUT"

    {
        echo ""
        echo "=============================================="
        echo " STOW CONFLICTS"
        echo "=============================================="
        for f in "${STOW_ERRORS[@]}"; do
            echo "   ~ $f"
        done
        echo " → Remove these files manually and re-run update.sh"
    } >> "$REPORT_FILE"
else
    ok "Config symlinks refreshed"
    echo "" >> "$REPORT_FILE"
    echo " STOW: Config symlinks refreshed successfully" >> "$REPORT_FILE"
fi

# ==========================================
# 8. WALLPAPERS SYNC (only if already cloned)
# ==========================================
section "Wallpapers"

if [[ -d "$WALLPAPERS_DIR/.git" ]]; then
    msg "Wallpapers repo found — pulling latest..."
    WALL_START=$SECONDS

    if git -C "$WALLPAPERS_DIR" fetch origin && \
       git -C "$WALLPAPERS_DIR" reset --hard origin/HEAD 2>/dev/null; then
        WALL_DURATION=$(( SECONDS - WALL_START ))
        ok "Wallpapers updated in ${WALL_DURATION}s"
        {
            echo ""
            echo "=============================================="
            echo " WALLPAPERS"
            echo "=============================================="
            echo " Status   : Updated successfully"
            echo " Duration : ${WALL_DURATION}s"
        } >> "$REPORT_FILE"
    else
        warn "Wallpapers update failed — keeping existing"
        {
            echo ""
            echo "=============================================="
            echo " WALLPAPERS"
            echo "=============================================="
            echo " Status : Update FAILED — existing wallpapers kept"
        } >> "$REPORT_FILE"
    fi
else
    msg "Wallpapers not cloned on this machine — skipping"
    {
        echo ""
        echo "=============================================="
        echo " WALLPAPERS"
        echo "=============================================="
        echo " Status : Not cloned on this machine — skipped"
    } >> "$REPORT_FILE"
fi

# ==========================================
# 9. RELOAD
# ==========================================
run_step "reload" "Reloading UI"

# ==========================================
# 10. DONE
# ==========================================
DURATION=$(( SECONDS - START_TIME ))

{
    echo ""
    echo "=============================================="
    echo " SUMMARY"
    echo "=============================================="
    echo " Total duration : ${DURATION}s"
    echo " Rolled forward : $LOCAL_SHORT → $REMOTE_SHORT"
    echo "=============================================="
    echo " END OF REPORT"
    echo "=============================================="
} >> "$REPORT_FILE"

echo ""
gum style \
    --foreground 82 --border-foreground 82 --border rounded \
    --align center --width 50 --padding "1 2" \
    "✓ UPDATE COMPLETE" \
    "$LOCAL_SHORT → $REMOTE_SHORT — ${DURATION}s"

echo ""
msg "Update report saved to: $REPORT_FILE"