#!/usr/bin/env bash
# =============================================================================
# Archer - Setup Entry Point
# Run after: git clone https://github.com/drunk-particles/Archer.git ~/Archer
# Usage: bash ~/Archer/setup.sh
# =============================================================================

set -euo pipefail

DOTS_DIR="$HOME/Archer"
export ARCHER_DIR="$HOME/.local/share/Archer"
INSTALL_DIR="$DOTS_DIR/install"

source "$INSTALL_DIR/lib/helpers.sh"

# ==========================================
# 1. DEPENDENCY CHECK
# ==========================================
ensure_installed gum

# ==========================================
# 2. SHOW LOGO
# ==========================================
clear
LOGO_FILE="$INSTALL_DIR/lib/logo.txt"
[[ -f "$LOGO_FILE" ]] && cat "$LOGO_FILE" && echo ""

# ==========================================
# 3. WARNING & CONFIRMATION
# ==========================================
echo ""
gum style \
    --foreground 196 --border-foreground 196 --border double \
    --align center --width 50 --padding "0 1" \
    "WARNING: SYSTEM MODIFICATION" \
    "This script will proceed with system changes"

echo ""
gum style --foreground 214 \
    "• SYMLINK files into ~/.config via Stow" \
    "• INSTALL packages via pacman and yay" \
    "• SETUP binaries, fonts, and desktop apps" \
    "• CONFIGURE system settings and services" \
    "• CHANGE your default shell to Zsh" \
    "• INSTALL Hyprland plugins via hyprpm"

echo ""
gum confirm "Understood. Proceed?" || { msg "Aborted safely."; exit 0; }

# ==========================================
# 4. INSTALL MODE SELECTION
# ==========================================
echo ""
gum style \
    --foreground 117 --border-foreground 117 --border rounded \
    --align center --width 50 --padding "0 1" \
    "SELECT INSTALL MODE"

echo ""
gum style --foreground 245 \
    "  minimal  — core packages only, installs fast" \
    "  complete — everything including heavy/optional apps"

echo ""
export INSTALL_MODE
INSTALL_MODE=$(gum choose --cursor "▶ " --selected.foreground 82 "minimal" "complete")
ok "Mode selected: $INSTALL_MODE"

# ==========================================
# 5. LINK ARCHER INTO ~/.local/share/Archer
# ==========================================
msg "Linking Archer to $ARCHER_DIR..."
mkdir -p "$HOME/.local/share"
ln -snf "$DOTS_DIR" "$ARCHER_DIR"
mkdir -p "$HOME/.local/state/Archer/toggles/hypr"
ok "Archer linked to $ARCHER_DIR"

# ==========================================
# 6. MAKE ALL SCRIPTS EXECUTABLE
# ==========================================
msg "Setting executable permissions..."
find "$DOTS_DIR" -type f \( \
    -name "*.sh" \
    -o -name "*.bash" \
    -o -path "*/bin/*" \
    -o -path "*/scripts/*" \
\) -exec chmod +x {} +
chmod +x "$DOTS_DIR/setup.sh" "$DOTS_DIR/update.sh"
ok "Script permissions set"

# ==========================================
# 7. RUN INSTALL STEPS
# ==========================================
START_TIME=$SECONDS

run_step() {
    local script="$1"
    local label="$2"
    local critical="${3:-false}"

    echo ""
    section "$label"

    local full_path="$INSTALL_DIR/$script"

    if [[ ! -f "$full_path" ]]; then
        warn "$script not found — skipping"
        return
    fi

    chmod +x "$full_path"

    if [[ "$critical" == "true" ]]; then
        bash "$full_path" || die "$label failed. Stopping."
    else
        bash "$full_path" || warn "$label had errors — continuing"
    fi

    ok "$label done"
}

# ── Packages ──────────────────────────────────────────────────────────────────
run_step "packaging/packages-pacman"  "Installing pacman packages"     true
run_step "packaging/packages-aur"     "Installing AUR packages"        true

# ── Shell ─────────────────────────────────────────────────────────────────────
run_step "config/zsh.sh"              "Setting up Zsh"                 false

# ── Configs & dotfiles ────────────────────────────────────────────────────────
run_step "config/dotfiles.sh"         "Symlinking config files"        true
run_step "config/pam.sh"             "Installing PAM files"           false
run_step "config/fonts.sh"            "Installing fonts"               false
run_step "config/applications.sh"     "Setting up applications"        false

# ── System tweaks ─────────────────────────────────────────────────────────────
run_step "system/fd-limit.sh"         "Raising file descriptor limits" false
run_step "system/file-watchers.sh"    "Increasing file watchers"       false
run_step "system/sudo-tries.sh"       "Configuring sudo tries"         false
run_step "system/input-group.sh"      "Adding user to input group"     false
run_step "system/ssh-flakiness.sh"    "Fixing SSH flakiness"           false
run_step "system/network.sh"          "Configuring network"            false
run_step "system/user-dirs.sh"        "Setting up user directories"    false
run_step "system/firewall.sh"         "Configuring firewall"           false
run_step "system/git.sh"              "Configuring git"                false
run_step "system/mimetypes.sh"        "Setting default apps"           false

# ── Hardware ──────────────────────────────────────────────────────────────────
run_step "hardware/bluetooth.sh"          "Configuring Bluetooth"          false
run_step "hardware/wifi-powersave.sh"     "WiFi powersave rules"           false
run_step "hardware/fast-shutdown.sh"      "Fast shutdown config"           false
run_step "hardware/unmount-fuse.sh"       "FUSE unmount hook"              false
run_step "hardware/swayosd.sh"            "Enabling SwayOSD"               false
run_step "hardware/recover-monitor.sh"    "Monitor recovery service"       false
#run_step "hardware/monitor-autodetect.sh" "Auto-detecting monitors"       false

# ── Extras ────────────────────────────────────────────────────────────────────
run_step "extras/thinkfan.sh"         "Configuring Thinkfan"           false
run_step "extras/easyeffects.sh"      "Setting up EasyEffects DSP"     false
run_step "extras/gpu-driver.sh"       "Installing GPU drivers"         false
run_step "extras/howdy.sh"            "Setting up Howdy face recognition" false

# ── Login ─────────────────────────────────────────────────────────────────────
#run_step "login/sddm.sh"              "Setting up SDDM"                false
#run_step "login/plymouth.sh"          "Setting up Plymouth"            false

# ── Services ──────────────────────────────────────────────────────────────────
run_step "services/system-services.sh" "Enabling system services"      false
run_step "services/user-services.sh"   "Enabling user services"        false

# ── Plugins ───────────────────────────────────────────────────────────────────
run_step "extras/plugins.sh"          "Installing Hyprland plugins"    false

# ── Wallpapers (optional) ─────────────────────────────────────────────────────
echo ""
if gum confirm "Clone Wallpapers repository to ~/Wallpapers?"; then
    run_step "extras/wallpapers.sh"   "Cloning Wallpapers"             false
else
    msg "Wallpapers skipped."
fi

# ── Reload ────────────────────────────────────────────────────────────────────
run_step "services/reload.sh"         "Reloading UI"                   false

# ==========================================
# 8. DONE
# ==========================================
DURATION=$(( SECONDS - START_TIME ))
echo ""
gum style \
    --foreground 82 --border-foreground 82 --border rounded \
    --align center --width 50 --padding "1 2" \
    "✓ ALL DONE!" \
    "Mode: $INSTALL_MODE — Finished in ${DURATION}s"

echo ""
if [[ "$INSTALL_MODE" == "minimal" ]]; then
    gum style --foreground 245 \
        "  To install remaining packages later, run:" \
        "  INSTALL_MODE=complete bash ~/Archer/install/packaging/packages-pacman" \
        "  INSTALL_MODE=complete bash ~/Archer/install/packaging/packages-aur"
    echo ""
fi

if gum confirm "Reboot now?"; then
    msg "Rebooting..."
    sudo reboot
else
    msg "Reboot skipped. Please reboot manually later."
fi