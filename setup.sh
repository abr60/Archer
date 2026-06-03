#!/usr/bin/env bash
# =============================================================================
# Archer - Setup Entry Point
# Run after: git clone https://github.com/drunk-particles/Archer.git ~/Archer
# Usage: bash ~/Archer/setup.sh
# =============================================================================

set -euo pipefail

DOTS_DIR="$HOME/Archer"

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
# 2. SHOW LOGO
# ==========================================
clear
LOGO_FILE="$DOTS_DIR/install/lib/logo.txt"
if [[ -f "$LOGO_FILE" ]]; then
    cat "$LOGO_FILE"
    echo ""
fi

# ==========================================
# 3. WARNING & CONFIRMATION
# ==========================================
echo ""
gum style \
    --foreground 196 \
    --border-foreground 196 \
    --border double \
    --align center \
    --width 50 \
    --padding "0 1" \
    "WARNING: SYSTEM MODIFICATION" "This script will proceed with system changes"

echo ""
gum style --foreground 214 \
    "• OVERWRITE files in ~/.config and ~/.local" \
    "• INSTALL packages via pacman and yay" \
    "• SETUP binaries and desktop apps" \
    "• COPY fonts and themes" \
    "• CHANGE your default shell to Zsh" \
    "• INSTALL Hyprland plugins via hyprpm"

echo ""
gum confirm "Understood. Proceed?" || { msg "Aborted safely."; exit 0; }

# ==========================================
# 4. RUN SUB-SCRIPTS
# ==========================================
INSTALL_DIR="$DOTS_DIR/install"
START_TIME=$SECONDS

run_step() {
    local script="$1"
    local label="$2"
    local critical="${3:-true}"

    echo ""
    msg "$label"

    if [[ ! -f "$INSTALL_DIR/$script" ]]; then
        warn "$script not found — skipping"
        return
    fi

    chmod +x "$INSTALL_DIR/$script"

    if [[ "$critical" == "true" ]]; then
        bash "$INSTALL_DIR/$script" || die "$label failed. Stopping."
    else
        bash "$INSTALL_DIR/$script" || warn "$label failed — continuing anyway"
    fi

    ok "$label done"
}

# --- Step 1: Packages first (everything else depends on these) ---
run_step "packages-pacman"  "Installing pacman packages"       true
run_step "packages-aur"     "Installing AUR packages"          true

# --- Step 2: Shell ---
run_step "zsh"              "Setting up Zsh"                   false

# --- Step 3: Configs & dotfiles ---
run_step "configs"          "Copying config files"             true
run_step "fonts"            "Installing fonts"                 false

# --- Step 4: Hardware & system ---
run_step "thinkfan"         "Configuring Thinkfan"             false
run_step "greetd"           "Setting up greetd"                false

# --- Step 5: Applications ---
run_step "applications"     "Setting up binaries and desktop apps"  false
run_step "easyeffects"      "Setting up EasyEffects DSP"       false
#run_step "waydroid"         "Configuring Waydroid networking"  false

# --- Step 6: Hyprland ---
# plugins excluded

# --- Step 7: Services & reload ---
run_step "services"         "Enabling systemd services"        false
run_step "reload"           "Reloading environment"            false

# ==========================================
# 5. DONE & REBOOT
# ==========================================
DURATION=$(( SECONDS - START_TIME ))
echo ""
gum style \
    --foreground 82 --border-foreground 82 --border rounded \
    --align center --width 50 --padding "1 2" \
    "✓ ALL DONE!" \
    "Finished in ${DURATION}s"

echo ""
if gum confirm "Reboot now?"; then
    msg "Rebooting..."
    sudo reboot
else
    msg "Reboot skipped. Please reboot manually later."
fi