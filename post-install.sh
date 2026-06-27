#!/usr/bin/env bash
# =============================================================================
# Archer - Post-Install Wizard
# Runs automatically on first login via autostart.lua.
# Phase 1: Interview — one question at a time, logo always visible
# Phase 2: Confirm  — summary table, loop back if rejected
# Phase 3: Execute  — run in order
# =============================================================================

set -uo pipefail

DOTS_DIR="$HOME/Archer"
export INSTALL_DIR="$DOTS_DIR/install"
STATE_DIR="$HOME/.local/state/Archer/post-install"
LOG_DIR="$HOME/.local/state/Archer/logs"
LOG_FILE="$LOG_DIR/post-install.log"

mkdir -p "$STATE_DIR" "$LOG_DIR"

source "$INSTALL_DIR/lib/helpers.sh"

# =============================================================================
# HELPERS
# =============================================================================

is_done()   { [[ -f "$STATE_DIR/$1.done" ]]; }
mark_done() { touch "$STATE_DIR/$1.done"; }

is_thinkpad() {
    local dmi="/sys/devices/virtual/dmi/id"
    for file in product_family product_name board_name sys_vendor; do
        [[ -r "$dmi/$file" ]] || continue
        grep -qi "thinkpad" "$dmi/$file" && return 0
    done
    return 1
}

# Clear + reprint logo before each screen (logo always on top)
show_screen() {
    print_logo
}

# Logo + titled question screen
# Usage: question_screen "Title" "Subtitle (muted, optional)"
question_screen() {
    show_screen
    gum style \
        --foreground "$C_PRIMARY" --border-foreground "$C_BORDER" --border normal \
        --width "$TERM_WIDTH" --padding "0 1" \
        "  $1"
    [[ -n "${2:-}" ]] && echo "" && gum style \
        --foreground "$C_MUTED" \
        --padding "0 0 0 $PADDING_LEFT" \
        "  $2"
    echo ""
}

# =============================================================================
# INTRO SCREEN
# =============================================================================
show_screen

gum style \
    --foreground "$C_PRIMARY" --border-foreground "$C_BORDER" --border rounded \
    --align center --width "$TERM_WIDTH" --padding "1 2" \
    "Archer Post-Install Wizard" \
    "Answer a few questions, then sit back."

echo ""
gum style \
    --foreground "$C_MUTED" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Each step is optional. Completed steps won't repeat." \
    "  You'll get a summary before anything runs."

echo ""
gum confirm "Ready?" || { msg "Aborted. Run ~/Archer/post-install.sh anytime."; exit 0; }

# =============================================================================
# PHASE 1 — INTERVIEW (one question at a time, logo always on top)
# =============================================================================

run_interview() {
    DO_EXTRA=false
    DO_GIT=false;       GIT_NAME="";  GIT_EMAIL=""
    DO_TIMEZONE=false;  TZ_CHOICE=""
    DO_BROWSER=false;   BROWSER_CHOICE=""
    DO_GPU=false
    DO_PLUGINS=false
    DO_FINGERPRINT=false
    DO_HOWDY=false
    DO_THINKFAN=false
    DO_EASYEFFECTS=false
    DO_WAYDROID=false
    DO_WALLPAPERS=false
    DO_SPICETIFY=false
    DO_SSH=false;       SSH_EMAIL=""
    DO_LOCALE=false;    LOCALE_CHOICE=""

    # --- Extra Packages ---
    if ! is_done "extra-packages"; then
        question_screen "Extra Packages" "VSCode, Obsidian, Telegram, yazi, kdenlive..."
        gum confirm "Install extras?" && DO_EXTRA=true || true
    fi

    # --- Git ---
    if ! is_done "git"; then
        question_screen "Git Identity" "Set global username and email."
        if gum confirm "Set up Git?"; then
            DO_GIT=true
            echo ""
            GIT_NAME=$(gum input --placeholder "Your Name")
            GIT_EMAIL=$(gum input --placeholder "your@email.com")
        fi
    fi

    # --- Timezone ---
    if ! is_done "timezone"; then
        question_screen "Timezone"
        if gum confirm "Set timezone?"; then
            DO_TIMEZONE=true
            echo ""
            TZ_CHOICE=$(timedatectl list-timezones | gum filter --placeholder "Search timezone...")
        fi
    fi

    # --- Default Browser ---
    if ! is_done "browser"; then
        question_screen "Default Browser"
        if gum confirm "Set default browser?"; then
            DO_BROWSER=true
            echo ""
            BROWSER_CHOICE=$(gum choose --cursor "▶ " "google-chrome" "brave-browser" "firefox" "chromium")
        fi
    fi

    # --- GPU Drivers ---
    if ! is_done "gpu-drivers"; then
        question_screen "GPU Drivers" "Install drivers for your hardware."
        gum confirm "Install GPU drivers?" && DO_GPU=true || true
    fi

    # --- Hyprland Plugins ---
    if ! is_done "hyprland-plugins"; then
        question_screen "Hyprland Plugins" "Installed via hyprpm."
        gum confirm "Install plugins?" && DO_PLUGINS=true || true
    fi

    # --- Fingerprint ---
    if is_laptop && ! is_done "fingerprint"; then
        question_screen "Fingerprint" "Enroll for sudo and login authentication."
        gum confirm "Enroll fingerprint?" && DO_FINGERPRINT=true || true
    fi

    # --- Howdy ---
    if ! is_done "howdy"; then
        question_screen "Howdy Face Recognition" "Enroll face for sudo authentication."
        gum confirm "Set up Howdy?" && DO_HOWDY=true || true
    fi

    # --- ThinkPad specific ---
    if is_thinkpad; then
        if ! is_done "thinkfan"; then
            question_screen "Thinkfan  ·  ThinkPad detected" "Configure fan control."
            gum confirm "Set up Thinkfan?" && DO_THINKFAN=true || true
        fi

        if ! is_done "easyeffects"; then
            question_screen "EasyEffects  ·  ThinkPad T14 G2" "Dolby-tuned audio presets."
            gum confirm "Set up EasyEffects?" && DO_EASYEFFECTS=true || true
        fi
    fi

    # --- Waydroid ---
    if ! is_done "waydroid"; then
        question_screen "Waydroid" "Android container."
        gum confirm "Set up Waydroid?" && DO_WAYDROID=true || true
    fi

    # --- Wallpapers ---
    if ! is_done "wallpapers"; then
        question_screen "Wallpapers" "Clone Archer wallpapers repo to ~/Wallpapers."
        gum confirm "Clone wallpapers?" && DO_WALLPAPERS=true || true
    fi

    # --- Spicetify ---
    if ! is_done "spicetify"; then
        question_screen "Spicetify" "Apply theme to Spotify."
        gum confirm "Set up Spicetify?" && DO_SPICETIFY=true || true
    fi

    # --- SSH Key ---
    if ! is_done "ssh"; then
        question_screen "SSH Key" "ED25519 key — public key shown after generation."
        if gum confirm "Generate SSH key?"; then
            DO_SSH=true
            echo ""
            SSH_EMAIL=$(gum input --placeholder "your@email.com")
        fi
    fi

    # --- Locale ---
    if ! is_done "locale"; then
        question_screen "Locale" "Set system locale."
        if gum confirm "Set locale?"; then
            DO_LOCALE=true
            echo ""
            LOCALE_CHOICE=$(gum input --placeholder "en_US.UTF-8")
        fi
    fi
}

# =============================================================================
# PHASE 2 — SUMMARY TABLE + CONFIRM LOOP
# =============================================================================

show_summary() {
    show_screen
    gum style \
        --foreground "$C_ACCENT" --border-foreground "$C_ACCENT" --border rounded \
        --align center --width "$TERM_WIDTH" --padding "0 1" \
        "Does this look right?"

    echo ""

    local rows="Step,Value"
    [[ "$DO_EXTRA"       == true ]] && rows+=$'\n'"Extra packages,Install"
    [[ "$DO_GIT"         == true ]] && rows+=$'\n'"Git identity,$GIT_NAME <$GIT_EMAIL>"
    [[ "$DO_TIMEZONE"    == true ]] && rows+=$'\n'"Timezone,$TZ_CHOICE"
    [[ "$DO_BROWSER"     == true ]] && rows+=$'\n'"Browser,$BROWSER_CHOICE"
    [[ "$DO_GPU"         == true ]] && rows+=$'\n'"GPU drivers,Install"
    [[ "$DO_PLUGINS"     == true ]] && rows+=$'\n'"Hyprland plugins,Install"
    [[ "$DO_FINGERPRINT" == true ]] && rows+=$'\n'"Fingerprint,Enroll"
    [[ "$DO_HOWDY"       == true ]] && rows+=$'\n'"Howdy,Enroll"
    [[ "$DO_THINKFAN"    == true ]] && rows+=$'\n'"Thinkfan,Configure"
    [[ "$DO_EASYEFFECTS" == true ]] && rows+=$'\n'"EasyEffects,Install presets"
    [[ "$DO_WAYDROID"    == true ]] && rows+=$'\n'"Waydroid,Install"
    [[ "$DO_WALLPAPERS"  == true ]] && rows+=$'\n'"Wallpapers,Clone"
    [[ "$DO_SPICETIFY"   == true ]] && rows+=$'\n'"Spicetify,Apply"
    [[ "$DO_SSH"         == true ]] && rows+=$'\n'"SSH key,$SSH_EMAIL"
    [[ "$DO_LOCALE"      == true ]] && rows+=$'\n'"Locale,$LOCALE_CHOICE"

    if [[ "$rows" == "Step,Value" ]]; then
        gum style \
            --foreground "$C_MUTED" \
            --padding "0 0 0 $PADDING_LEFT" \
            "  Nothing selected — nothing will run."
    else
        echo "$rows" | gum table \
            --border rounded \
            --border.foreground "$C_BORDER" \
            --cell.foreground "$C_MUTED" \
            --header.foreground "$C_PRIMARY" \
            -p
    fi

    echo ""
}

# Interview + confirm loop
while true; do
    run_interview
    show_summary

    if gum confirm "Yes, run it" --affirmative="Yes" --negative="No, change it"; then
        break
    else
        gum style \
            --foreground "$C_MUTED" \
            --padding "0 0 0 $PADDING_LEFT" \
            "  Starting over..."
        sleep 1
    fi
done

# =============================================================================
# PHASE 3 — EXECUTE
# =============================================================================
show_screen
gum style \
    --foreground "$C_ACCENT" --border-foreground "$C_ACCENT" --border rounded \
    --align center --width "$TERM_WIDTH" --padding "0 1" \
    "Phase 3 — Executing"

echo ""
START_TIME=$SECONDS

[[ "$DO_EXTRA" == true ]] && {
    section "Extra Packages"
    bash "$INSTALL_DIR/packaging/packages" extra && mark_done "extra-packages" || warn "Extra packages had errors"
}

[[ "$DO_GIT" == true ]] && {
    section "Git Identity"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    mark_done "git"
    ok "Git identity set"
}

[[ "$DO_TIMEZONE" == true ]] && {
    section "Timezone"
    sudo timedatectl set-timezone "$TZ_CHOICE"
    mark_done "timezone"
    ok "Timezone → $TZ_CHOICE"
}

[[ "$DO_BROWSER" == true ]] && {
    section "Default Browser"
    xdg-settings set default-web-browser "${BROWSER_CHOICE}.desktop"
    mark_done "browser"
    ok "Browser → $BROWSER_CHOICE"
}

[[ "$DO_GPU" == true ]] && {
    section "GPU Drivers"
    run_step "extras/gpu-driver.sh" "GPU drivers" false "$LOG_FILE"
    mark_done "gpu-drivers"
}

[[ "$DO_PLUGINS" == true ]] && {
    section "Hyprland Plugins"
    run_step "extras/plugins.sh" "Hyprland plugins" false "$LOG_FILE"
    mark_done "hyprland-plugins"
}

[[ "$DO_FINGERPRINT" == true ]] && {
    section "Fingerprint"
    fprintd-enroll && mark_done "fingerprint" && ok "Fingerprint enrolled" || warn "Fingerprint had errors"
}

[[ "$DO_HOWDY" == true ]] && {
    section "Howdy"
    sudo howdy add && mark_done "howdy" && ok "Howdy enrolled" || warn "Howdy had errors"
}

[[ "$DO_THINKFAN" == true ]] && {
    section "Thinkfan"
    run_step "extras/thinkfan.sh" "Thinkfan" false "$LOG_FILE"
    mark_done "thinkfan"
}

[[ "$DO_EASYEFFECTS" == true ]] && {
    section "EasyEffects"
    run_step "extras/easyeffects.sh" "EasyEffects" false "$LOG_FILE"
    mark_done "easyeffects"
}

[[ "$DO_WAYDROID" == true ]] && {
    section "Waydroid"
    run_step "extras/waydroid.sh" "Waydroid" false "$LOG_FILE"
    mark_done "waydroid"
}

[[ "$DO_WALLPAPERS" == true ]] && {
    section "Wallpapers"
    run_step "extras/wallpapers.sh" "Wallpapers" false "$LOG_FILE"
    mark_done "wallpapers"
}

[[ "$DO_SPICETIFY" == true ]] && {
    section "Spicetify"
    spicetify apply >> "$LOG_FILE" 2>&1 && mark_done "spicetify" && ok "Spicetify done" || warn "Spicetify had errors"
}

[[ "$DO_SSH" == true ]] && {
    section "SSH Key"
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
    mark_done "ssh"
    echo ""
    gum style \
        --foreground "$C_TEAL" \
        --padding "0 0 0 $PADDING_LEFT" \
        "  Public key (add to GitHub/GitLab):"
    echo ""
    gum style \
        --foreground "$C_MUTED" \
        --padding "0 0 0 $PADDING_LEFT" \
        "$(cat "$HOME/.ssh/id_ed25519.pub")"
    ok "SSH key generated"
}

[[ "$DO_LOCALE" == true ]] && {
    section "Locale"
    sudo localectl set-locale LANG="$LOCALE_CHOICE"
    mark_done "locale"
    ok "Locale → $LOCALE_CHOICE"
}

# =============================================================================
# DONE
# =============================================================================
DURATION=$(( SECONDS - START_TIME ))
echo ""
gum style \
    --foreground "$C_SUCCESS" --border-foreground "$C_SUCCESS" --border rounded \
    --align center --width "$TERM_WIDTH" --padding "1 2" \
    "✓ Post-install complete!" \
    "Finished in ${DURATION}s"

echo ""
gum style \
    --foreground "$C_ERROR" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Remove the autostart entry when done:" \
    "  ~/.config/hypr/autostart.lua" \
    "  → comment out the post-install.sh line"

echo ""
gum style \
    --foreground "$C_MUTED" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Re-run anytime:  bash ~/Archer/post-install.sh" \
    "  Force redo:      rm $STATE_DIR/<step>.done"

echo ""
gum confirm "Reboot now?" && sudo reboot || msg "Reboot skipped."