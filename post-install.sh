#!/usr/bin/env bash
# =============================================================================
# Archer - Post-Install Wizard
# Runs automatically on first login via autostart.lua.
# Guides you through optional setup steps that require user input.
#
# When finished, comment out this line in ~/.config/hypr/autostart.lua:
#   a.exec_on_start("xdg-terminal-exec bash ~/Archer/post-install.sh")
# =============================================================================

set -euo pipefail

DOTS_DIR="$HOME/Archer"
INSTALL_DIR="$DOTS_DIR/install"

source "$INSTALL_DIR/lib/helpers.sh"

# ==========================================
# SHOW LOGO
# ==========================================
clear
LOGO_FILE="$INSTALL_DIR/lib/logo.txt"
[[ -f "$LOGO_FILE" ]] && cat "$LOGO_FILE" && echo ""

gum style \
    --foreground 117 --border-foreground 117 --border rounded \
    --align center --width 54 --padding "1 2" \
    "Archer Post-Install Wizard" \
    "Each step is optional — skip anything you don't need."

echo ""
gum confirm "Ready to begin?" || { msg "Aborted. Run ~/Archer/post-install.sh again anytime."; exit 0; }

# ==========================================
# HELPER
# ==========================================
run_step() {
    local script="$1"
    local label="$2"

    local full_path="$INSTALL_DIR/$script"

    if [[ ! -f "$full_path" ]]; then
        warn "$script not found — skipping"
        return
    fi

    chmod +x "$full_path"
    bash "$full_path" || warn "$label had errors — continuing"
    ok "$label done"
}

step() {
    local label="$1"
    echo ""
    gum style --foreground 117 --border-foreground 117 --border normal \
        --width 54 --padding "0 1" "  $label"
}

# ==========================================
# 1. GIT
# ==========================================
step "Git Identity"
gum style --foreground 245 "Set your global git username and email."
echo ""
if gum confirm "Set up Git identity?"; then
    GIT_NAME=$(gum input --placeholder "Your Name")
    GIT_EMAIL=$(gum input --placeholder "your@email.com")
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    ok "Git identity set: $GIT_NAME <$GIT_EMAIL>"
else
    msg "Git skipped."
fi

# ==========================================
# 2. TIMEZONE
# ==========================================
step "Timezone"
gum style --foreground 245 "Select your timezone (e.g. Asia/Dhaka)."
echo ""
if gum confirm "Set timezone?"; then
    TZ=$(timedatectl list-timezones | gum filter --placeholder "Search timezone...")
    sudo timedatectl set-timezone "$TZ"
    ok "Timezone set to $TZ"
else
    msg "Timezone skipped."
fi

# ==========================================
# 3. DEFAULT BROWSER
# ==========================================
step "Default Browser"
gum style --foreground 245 "Choose your default browser."
echo ""
if gum confirm "Set default browser?"; then
    BROWSER=$(gum choose --cursor "▶ " "brave-browser" "google-chrome" "firefox" "chromium")
    xdg-settings set default-web-browser "${BROWSER}.desktop"
    ok "Default browser set to $BROWSER"
else
    msg "Browser skipped."
fi

# ==========================================
# 4. DEFAULT TERMINAL
# ==========================================
step "Default Terminal"
gum style --foreground 245 "Choose your default terminal."
echo ""
if gum confirm "Set default terminal?"; then
    TERMINAL=$(gum choose --cursor "▶ " "ghostty" "kitty" "foot" "alacritty")
    default-terminal "$TERMINAL"
    ok "Default terminal set to $TERMINAL"
else
    msg "Terminal skipped."
fi

# ==========================================
# 5. COMPLETE PACKAGES
# ==========================================
step "Complete Packages"
gum style --foreground 245 \
    "Install heavy/optional packages:" \
    "Spotify, VSCode, Typora, MPV plugins, Chrome..."
echo ""
if gum confirm "Install complete packages?"; then
    INSTALL_MODE=complete bash "$INSTALL_DIR/packaging/packages-pacman" || warn "pacman-heavy had errors"
    INSTALL_MODE=complete bash "$INSTALL_DIR/packaging/packages-aur"    || warn "aur-heavy had errors"
    ok "Complete packages done"
else
    msg "Complete packages skipped."
fi

# ==========================================
# 6. GPU DRIVERS
# ==========================================
step "GPU Drivers"
gum style --foreground 245 "Install GPU drivers for your hardware."
echo ""
if gum confirm "Install GPU drivers?"; then
    run_step "extras/gpu-driver.sh" "GPU drivers"
else
    msg "GPU drivers skipped."
fi

# ==========================================
# 7. EASYEFFECTS DSP
# ==========================================
step "EasyEffects DSP"
gum style --foreground 245 "Set up EasyEffects audio presets."
echo ""
if gum confirm "Set up EasyEffects?"; then
    run_step "extras/easyeffects.sh" "EasyEffects"
else
    msg "EasyEffects skipped."
fi

# ==========================================
# 8. HYPRLAND PLUGINS
# ==========================================
step "Hyprland Plugins"
gum style --foreground 245 "Install plugins via hyprpm (scrolloverview etc.)."
echo ""
if gum confirm "Install Hyprland plugins?"; then
    run_step "extras/plugins.sh" "Hyprland plugins"
else
    msg "Plugins skipped."
fi

# ==========================================
# 9. HOWDY FACE RECOGNITION
# ==========================================
step "Howdy Face Recognition"
gum style --foreground 245 "Enroll your face for sudo authentication."
echo ""
if gum confirm "Set up Howdy face enrollment?"; then
    sudo howdy add
    ok "Howdy enrollment done"
else
    msg "Howdy skipped."
fi

# ==========================================
# 10. WALLPAPERS
# ==========================================
step "Wallpapers"
gum style --foreground 245 "Clone the Archer wallpapers repo to ~/Wallpapers."
echo ""
if gum confirm "Clone Wallpapers?"; then
    run_step "extras/wallpapers.sh" "Wallpapers"
else
    msg "Wallpapers skipped."
fi

# ==========================================
# 11. SDDM THEME
# ==========================================
step "SDDM Login Theme"
gum style --foreground 245 "Set up the SDDM login screen theme."
echo ""
if gum confirm "Set up SDDM theme?"; then
    run_step "login/sddm.sh" "SDDM theme"
else
    msg "SDDM skipped."
fi

# ==========================================
# 12. SPICETIFY
# ==========================================
step "Spicetify (Spotify theming)"
gum style --foreground 245 "Apply Spicetify theme to Spotify."
echo ""
if gum confirm "Set up Spicetify?"; then
    spicetify backup apply || warn "Spicetify had errors"
    ok "Spicetify done"
else
    msg "Spicetify skipped."
fi

# ==========================================
# DONE
# ==========================================
echo ""
gum style \
    --foreground 82 --border-foreground 82 --border rounded \
    --align center --width 54 --padding "1 2" \
    "✓ Post-install wizard complete!"

echo ""
gum style --foreground 196 \
    "  !! IMPORTANT — Remove the autostart line !!" \
    "  Comment out this line in ~/.config/hypr/autostart.lua:" \
    "  a.exec_on_start(\"xdg-terminal-exec bash ~/Archer/post-install.sh\")"

echo ""
gum style --foreground 245 \
    "  You can re-run individual steps anytime:" \
    "  bash ~/Archer/post-install.sh"

echo ""
if gum confirm "Reboot now?"; then
    sudo reboot
else
    msg "Reboot skipped."
fi
