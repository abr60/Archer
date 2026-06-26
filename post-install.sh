#!/usr/bin/env bash
# =============================================================================
# Archer - Post-Install Wizard
# Runs automatically on first login via autostart.lua.
# Phase 1: Interview — collect all choices
# Phase 2: Confirm  — show what will run
# Phase 3: Execute  — run everything in order
# =============================================================================

set -uo pipefail

DOTS_DIR="$HOME/Archer"
INSTALL_DIR="$DOTS_DIR/install"
STATE_DIR="$HOME/.local/state/Archer/post-install"
LOG_DIR="$HOME/.local/state/Archer/logs"
LOG_FILE="$LOG_DIR/post-install.log"

mkdir -p "$STATE_DIR" "$LOG_DIR"

source "$INSTALL_DIR/lib/helpers.sh"

# =============================================================================
# HELPERS
# =============================================================================

is_done() { [[ -f "$STATE_DIR/$1.done" ]]; }
mark_done() { touch "$STATE_DIR/$1.done"; }

is_thinkpad() {
    local dmi="/sys/devices/virtual/dmi/id"

    for file in product_family product_name board_name sys_vendor; do
        [[ -r "$dmi/$file" ]] || continue

        if grep -qi "thinkpad" "$dmi/$file"; then
            return 0
        fi
    done

    return 1
}

run_step() {
    local script="$1"
    local label="$2"
    local full_path="$INSTALL_DIR/$script"

    if [[ ! -f "$full_path" ]]; then
        warn "$script not found — skipping"
        return
    fi

    chmod +x "$full_path"
    bash "$full_path" >> "$LOG_FILE" 2>&1 || warn "$label had errors — check $LOG_FILE"
}

step_header() {
    echo ""
    gum style \
        --foreground 117 --border-foreground 117 --border normal \
        --width 54 --padding "0 1" "  $1"
}

already_done() {
    local key="$1"
    local label="$2"
    if is_done "$key"; then
        gum style --foreground 245 "  ✓ $label — already completed (delete $STATE_DIR/$key.done to redo)"
        return 0
    fi
    return 1
}

# =============================================================================
# SHOW LOGO
# =============================================================================
clear
LOGO_FILE="$INSTALL_DIR/lib/logo.txt"
[[ -f "$LOGO_FILE" ]] && cat "$LOGO_FILE" && echo ""

gum style \
    --foreground 117 --border-foreground 117 --border rounded \
    --align center --width 54 --padding "1 2" \
    "Archer Post-Install Wizard" \
    "Answer a few questions, then sit back."

echo ""
gum style --foreground 245 \
    "  Each step is optional — skip anything you don't need." \
    "  Completed steps are remembered and won't repeat."

echo ""
gum confirm "Ready to begin?" || { msg "Aborted. Run ~/Archer/post-install.sh again anytime."; exit 0; }

# =============================================================================
# PHASE 1 — INTERVIEW
# =============================================================================
echo ""
gum style \
    --foreground 214 --border-foreground 214 --border rounded \
    --align center --width 54 --padding "0 1" \
    "Phase 1 — Your Choices"

# Collect all decisions into variables
DO_EXTRA=false
DO_GIT=false;        GIT_NAME="";   GIT_EMAIL=""
DO_TIMEZONE=false;   TZ_CHOICE=""
DO_BROWSER=false;    BROWSER_CHOICE=""
DO_GPU=false
DO_PLUGINS=false
DO_FINGERPRINT=false
DO_HOWDY=false
DO_THINKFAN=false
DO_EASYEFFECTS=false
DO_WAYDROID=false
DO_WALLPAPERS=false
DO_SPICETIFY=false
DO_SSH=false;        SSH_EMAIL=""
DO_LOCALE=false;     LOCALE_CHOICE=""

# --- Extra Packages ---
step_header "Extra Packages"
gum style --foreground 245 "Install optional apps: VSCode, Obsidian, Telegram, yazi, kdenlive..."
echo ""
if ! already_done "extra-packages" "Extra packages"; then
    gum confirm "Install extra packages?" && DO_EXTRA=true || true
fi

# --- Git ---
step_header "Git Identity"
gum style --foreground 245 "Set your global git username and email."
echo ""
if ! already_done "git" "Git identity"; then
    if gum confirm "Set up Git identity?"; then
        DO_GIT=true
        GIT_NAME=$(gum input --placeholder "Your Name")
        GIT_EMAIL=$(gum input --placeholder "your@email.com")
    fi
fi

# --- Timezone ---
step_header "Timezone"
gum style --foreground 245 "Select your timezone."
echo ""
if ! already_done "timezone" "Timezone"; then
    if gum confirm "Set timezone?"; then
        DO_TIMEZONE=true
        TZ_CHOICE=$(timedatectl list-timezones | gum filter --placeholder "Search timezone...")
    fi
fi

# --- Default Browser ---
step_header "Default Browser"
gum style --foreground 245 "Choose your default browser."
echo ""
if ! already_done "browser" "Default browser"; then
    if gum confirm "Set default browser?"; then
        DO_BROWSER=true
        BROWSER_CHOICE=$(gum choose --cursor "▶ " "google-chrome" "brave-browser" "firefox" "chromium")
    fi
fi

# --- GPU Drivers ---
step_header "GPU Drivers"
gum style --foreground 245 "Install GPU drivers for your hardware."
echo ""
if ! already_done "gpu-drivers" "GPU drivers"; then
    gum confirm "Install GPU drivers?" && DO_GPU=true || true
fi

# --- Hyprland Plugins ---
step_header "Hyprland Plugins"
gum style --foreground 245 "Install plugins via hyprpm (scrolloverview etc.)."
echo ""
if ! already_done "hyprland-plugins" "Hyprland plugins"; then
    gum confirm "Install Hyprland plugins?" && DO_PLUGINS=true || true
fi

# --- Fingerprint ---
if is_laptop; then
    step_header "Fingerprint Enrollment"
    gum style --foreground 245 "Enroll your fingerprint for sudo/login authentication."
    echo ""
    if ! already_done "fingerprint" "Fingerprint enrollment"; then
        gum confirm "Enroll fingerprint?" && DO_FINGERPRINT=true || true
    fi
fi

# --- Howdy ---
step_header "Howdy Face Recognition"
gum style --foreground 245 "Enroll your face for sudo authentication."
echo ""
if ! already_done "howdy" "Howdy face enrollment"; then
    gum confirm "Set up Howdy?" && DO_HOWDY=true || true
fi

# --- ThinkPad specific ---
if is_thinkpad; then
    step_header "Thinkfan  ·  ThinkPad detected"
    gum style --foreground 245 "Configure Thinkfan for thermal management."
    echo ""
    if ! already_done "thinkfan" "Thinkfan"; then
        gum confirm "Set up Thinkfan?" && DO_THINKFAN=true || true
    fi

    step_header "EasyEffects Presets  ·  ThinkPad T14 G2"
    gum style --foreground 245 "Install Dolby-tuned audio presets for your T14."
    echo ""
    if ! already_done "easyeffects" "EasyEffects presets"; then
        gum confirm "Set up EasyEffects presets?" && DO_EASYEFFECTS=true || true
    fi
fi

# --- Waydroid ---
step_header "Waydroid"
gum style --foreground 245 "Install and configure Waydroid (Android container)."
echo ""
if ! already_done "waydroid" "Waydroid"; then
    gum confirm "Set up Waydroid?" && DO_WAYDROID=true || true
fi

# --- Wallpapers ---
step_header "Wallpapers"
gum style --foreground 245 "Clone the Archer wallpapers repo to ~/Wallpapers."
echo ""
if ! already_done "wallpapers" "Wallpapers"; then
    gum confirm "Clone wallpapers?" && DO_WALLPAPERS=true || true
fi

# --- Spicetify ---
step_header "Spicetify"
gum style --foreground 245 "Apply Spicetify theme to Spotify."
echo ""
if ! already_done "spicetify" "Spicetify"; then
    gum confirm "Set up Spicetify?" && DO_SPICETIFY=true || true
fi

# --- SSH Key ---
step_header "SSH Key"
gum style --foreground 245 "Generate an ED25519 SSH key and display the public key."
echo ""
if ! already_done "ssh" "SSH key"; then
    if gum confirm "Generate SSH key?"; then
        DO_SSH=true
        SSH_EMAIL=$(gum input --placeholder "your@email.com")
    fi
fi

# --- Locale ---
step_header "Locale / Language"
gum style --foreground 245 "Set system locale (e.g. en_US.UTF-8)."
echo ""
if ! already_done "locale" "Locale"; then
    if gum confirm "Set locale?"; then
        DO_LOCALE=true
        LOCALE_CHOICE=$(gum input --placeholder "en_US.UTF-8")
    fi
fi

# =============================================================================
# PHASE 2 — CONFIRMATION SUMMARY
# =============================================================================
echo ""
gum style \
    --foreground 214 --border-foreground 214 --border rounded \
    --align center --width 54 --padding "0 1" \
    "Phase 2 — Confirm"

echo ""
gum style --foreground 117 "  The following steps will run:"
echo ""

[[ "$DO_EXTRA"        == true ]] && gum style --foreground 82 "  ✓ Extra packages"
[[ "$DO_GIT"          == true ]] && gum style --foreground 82 "  ✓ Git identity → $GIT_NAME <$GIT_EMAIL>"
[[ "$DO_TIMEZONE"     == true ]] && gum style --foreground 82 "  ✓ Timezone → $TZ_CHOICE"
[[ "$DO_BROWSER"      == true ]] && gum style --foreground 82 "  ✓ Default browser → $BROWSER_CHOICE"
[[ "$DO_GPU"          == true ]] && gum style --foreground 82 "  ✓ GPU drivers"
[[ "$DO_PLUGINS"      == true ]] && gum style --foreground 82 "  ✓ Hyprland plugins"
[[ "$DO_FINGERPRINT"  == true ]] && gum style --foreground 82 "  ✓ Fingerprint enrollment"
[[ "$DO_HOWDY"        == true ]] && gum style --foreground 82 "  ✓ Howdy face recognition"
[[ "$DO_THINKFAN"     == true ]] && gum style --foreground 82 "  ✓ Thinkfan"
[[ "$DO_EASYEFFECTS"  == true ]] && gum style --foreground 82 "  ✓ EasyEffects presets"
[[ "$DO_WAYDROID"     == true ]] && gum style --foreground 82 "  ✓ Waydroid"
[[ "$DO_WALLPAPERS"   == true ]] && gum style --foreground 82 "  ✓ Wallpapers"
[[ "$DO_SPICETIFY"    == true ]] && gum style --foreground 82 "  ✓ Spicetify"
[[ "$DO_SSH"          == true ]] && gum style --foreground 82 "  ✓ SSH key → $SSH_EMAIL"
[[ "$DO_LOCALE"       == true ]] && gum style --foreground 82 "  ✓ Locale → $LOCALE_CHOICE"

echo ""
gum confirm "Looks good? Run everything now?" || { msg "Aborted. No changes made."; exit 0; }

# =============================================================================
# PHASE 3 — EXECUTE
# =============================================================================
echo ""
gum style \
    --foreground 214 --border-foreground 214 --border rounded \
    --align center --width 54 --padding "0 1" \
    "Phase 3 — Executing"

START_TIME=$SECONDS

# --- Extra Packages ---
if [[ "$DO_EXTRA" == true ]]; then
    section "Extra Packages"
    bash "$INSTALL_DIR/packaging/packages" extra && mark_done "extra-packages" || warn "Extra packages had errors"
fi

# --- Git ---
if [[ "$DO_GIT" == true ]]; then
    section "Git Identity"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    mark_done "git"
    ok "Git identity set"
fi

# --- Timezone ---
if [[ "$DO_TIMEZONE" == true ]]; then
    section "Timezone"
    sudo timedatectl set-timezone "$TZ_CHOICE"
    mark_done "timezone"
    ok "Timezone set to $TZ_CHOICE"
fi

# --- Browser ---
if [[ "$DO_BROWSER" == true ]]; then
    section "Default Browser"
    xdg-settings set default-web-browser "${BROWSER_CHOICE}.desktop"
    mark_done "browser"
    ok "Default browser set to $BROWSER_CHOICE"
fi

# --- GPU ---
if [[ "$DO_GPU" == true ]]; then
    section "GPU Drivers"
    run_step "extras/gpu-driver.sh" "GPU drivers"
    mark_done "gpu-drivers"
    ok "GPU drivers done"
fi

# --- Plugins ---
if [[ "$DO_PLUGINS" == true ]]; then
    section "Hyprland Plugins"
    run_step "extras/plugins.sh" "Hyprland plugins"
    mark_done "hyprland-plugins"
    ok "Plugins done"
fi

# --- Fingerprint ---
if [[ "$DO_FINGERPRINT" == true ]]; then
    section "Fingerprint Enrollment"
    fprintd-enroll && mark_done "fingerprint" && ok "Fingerprint enrolled" || warn "Fingerprint enrollment had errors"
fi

# --- Howdy ---
if [[ "$DO_HOWDY" == true ]]; then
    section "Howdy Face Recognition"
    sudo howdy add && mark_done "howdy" && ok "Howdy enrolled" || warn "Howdy had errors"
fi

# --- Thinkfan ---
if [[ "$DO_THINKFAN" == true ]]; then
    section "Thinkfan"
    run_step "extras/thinkfan.sh" "Thinkfan"
    mark_done "thinkfan"
    ok "Thinkfan done"
fi

# --- EasyEffects ---
if [[ "$DO_EASYEFFECTS" == true ]]; then
    section "EasyEffects Presets"
    run_step "extras/easyeffects.sh" "EasyEffects"
    mark_done "easyeffects"
    ok "EasyEffects done"
fi

# --- Waydroid ---
if [[ "$DO_WAYDROID" == true ]]; then
    section "Waydroid"
    run_step "extras/waydroid.sh" "Waydroid"
    mark_done "waydroid"
    ok "Waydroid done"
fi

# --- Wallpapers ---
if [[ "$DO_WALLPAPERS" == true ]]; then
    section "Wallpapers"
    run_step "extras/wallpapers.sh" "Wallpapers"
    mark_done "wallpapers"
    ok "Wallpapers done"
fi

# --- Spicetify ---
if [[ "$DO_SPICETIFY" == true ]]; then
    section "Spicetify"
    spicetify backup apply >> "$LOG_FILE" 2>&1 && mark_done "spicetify" && ok "Spicetify done" || warn "Spicetify had errors"
fi

# --- SSH ---
if [[ "$DO_SSH" == true ]]; then
    section "SSH Key"
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
    mark_done "ssh"
    echo ""
    gum style --foreground 117 "  Your public key (add to GitHub/GitLab):"
    echo ""
    gum style --foreground 245 "$(cat "$HOME/.ssh/id_ed25519.pub")"
    ok "SSH key generated"
fi

# --- Locale ---
if [[ "$DO_LOCALE" == true ]]; then
    section "Locale"
    sudo localectl set-locale LANG="$LOCALE_CHOICE"
    mark_done "locale"
    ok "Locale set to $LOCALE_CHOICE"
fi

# =============================================================================
# DONE
# =============================================================================
DURATION=$(( SECONDS - START_TIME ))
echo ""
gum style \
    --foreground 82 --border-foreground 82 --border rounded \
    --align center --width 54 --padding "1 2" \
    "✓ Post-install wizard complete!" \
    "Finished in ${DURATION}s"

echo ""
gum style --foreground 196 \
    "  !! Remove the autostart line when done !!" \
    "  Comment out in ~/.config/hypr/autostart.lua:" \
    "  a.exec_on_start(\"xdg-terminal-exec bash ~/Archer/post-install.sh\")"

echo ""
gum style --foreground 245 \
    "  Re-run any step anytime:" \
    "  bash ~/Archer/post-install.sh" \
    "" \
    "  Force redo a completed step:" \
    "  rm ~/.local/state/Archer/post-install/<step>.done"

echo ""
if gum confirm "Reboot now?"; then
    sudo reboot
else
    msg "Reboot skipped. Reboot manually when ready."
fi