#!/usr/bin/env bash
# =============================================================================
# Archer - Post-Install Wizard
# Phase 1: Select  — multi-select, space to toggle
# Phase 2: Input   — collect details for steps that need them
# Phase 3: Confirm — summary table, loop back if rejected
# Phase 4: Execute — run in order with step counter
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

show_screen() { print_logo; }

# =============================================================================
# INTRO
# =============================================================================
show_screen

gum style \
    --foreground "$C_PRIMARY" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Post-Install Setup"

echo ""

gum style \
    --foreground "$C_MUTED" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Select what you want to set up." \
    "  Completed steps are hidden. Nothing runs until you confirm."

echo ""

# =============================================================================
# PHASE 1 — MULTI-SELECT
# =============================================================================

run_selection() {
    # Build pending options with tab-separated descriptions
    local items=()

    ! is_done "extra-packages"   && items+=("Extra Packages	VSCode, Obsidian, Telegram, yazi, kdenlive...")
    ! is_done "git"              && items+=("Git Identity	Set global name and email")
    ! is_done "gpu-drivers"      && items+=("GPU Drivers	Install drivers for your hardware")
    ! is_done "hyprland-plugins" && items+=("Hyprland Plugins	Installed via hyprpm")
    is_laptop && ! is_done "fingerprint" && items+=("Fingerprint	Enroll for sudo and login")
    ! is_done "howdy"            && items+=("Howdy	Face recognition for sudo")
    is_thinkpad && ! is_done "thinkfan"    && items+=("Thinkfan	Fan curve control (ThinkPad)")
    is_thinkpad && ! is_done "easyeffects" && items+=("EasyEffects	Dolby-tuned audio presets (ThinkPad)")
    ! is_done "waydroid"         && items+=("Waydroid	Android container")
    ! is_done "wallpapers"       && items+=("Wallpapers	Clone Archer wallpapers to ~/Wallpapers")
    ! is_done "spicetify"        && items+=("Spicetify	Apply theme to Spotify")
    ! is_done "ssh"              && items+=("SSH Key	Generate ED25519 key")

    if [[ ${#items[@]} -eq 0 ]]; then
        gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
            "  Nothing left to do — all steps are marked done."
        exit 0
    fi

    show_screen

    gum style \
        --foreground "$C_PRIMARY" \
        --padding "0 0 0 $PADDING_LEFT" \
        "  Post-Install Setup"

    echo ""

    SELECTED=$(printf '%s\n' "${items[@]}" | gum choose \
        --no-limit \
        --header "  space to toggle  ·  enter to confirm" \
        --height 20)

    echo ""
}

# =============================================================================
# PHASE 2 — COLLECT EXTRA INPUT
# =============================================================================

collect_inputs() {
    DO_EXTRA=false
    DO_GIT=false;  GIT_NAME=""; GIT_EMAIL=""
    DO_GPU=false
    DO_PLUGINS=false
    DO_FINGERPRINT=false
    DO_HOWDY=false
    DO_THINKFAN=false
    DO_EASYEFFECTS=false
    DO_WAYDROID=false
    DO_WALLPAPERS=false
    DO_SPICETIFY=false
    DO_SSH=false;  SSH_EMAIL=""

    grep -q "^Extra Packages"    <<< "$SELECTED" && DO_EXTRA=true
    grep -q "^GPU Drivers"       <<< "$SELECTED" && DO_GPU=true
    grep -q "^Hyprland Plugins"  <<< "$SELECTED" && DO_PLUGINS=true
    grep -q "^Fingerprint"       <<< "$SELECTED" && DO_FINGERPRINT=true
    grep -q "^Howdy"             <<< "$SELECTED" && DO_HOWDY=true
    grep -q "^Thinkfan"          <<< "$SELECTED" && DO_THINKFAN=true
    grep -q "^EasyEffects"       <<< "$SELECTED" && DO_EASYEFFECTS=true
    grep -q "^Waydroid"          <<< "$SELECTED" && DO_WAYDROID=true
    grep -q "^Wallpapers"        <<< "$SELECTED" && DO_WALLPAPERS=true
    grep -q "^Spicetify"         <<< "$SELECTED" && DO_SPICETIFY=true

    if grep -q "^Git Identity" <<< "$SELECTED"; then
        DO_GIT=true
        show_screen
        gum style --foreground "$C_PRIMARY" --padding "0 0 0 $PADDING_LEFT" \
            "  Git Identity"
        echo ""
        GIT_NAME=$(gum input --placeholder "Your Name")
        GIT_EMAIL=$(gum input --placeholder "your@email.com")
        echo ""
    fi

    if grep -q "^SSH Key" <<< "$SELECTED"; then
        DO_SSH=true
        show_screen
        gum style --foreground "$C_PRIMARY" --padding "0 0 0 $PADDING_LEFT" \
            "  SSH Key  —  ED25519"
        echo ""
        SSH_EMAIL=$(gum input --placeholder "your@email.com")
        echo ""
    fi
}

# =============================================================================
# PHASE 3 — SUMMARY + CONFIRM LOOP
# =============================================================================

show_summary() {
    show_screen

    gum style --foreground "$C_ACCENT" --padding "0 0 0 $PADDING_LEFT" \
        "  Review"
    echo ""

    local rows="Step,Action"
    [[ "$DO_EXTRA"       == true ]] && rows+=$'\n'"Extra Packages,Install"
    [[ "$DO_GIT"         == true ]] && rows+=$'\n'"Git Identity,$GIT_NAME <$GIT_EMAIL>"
    [[ "$DO_GPU"         == true ]] && rows+=$'\n'"GPU Drivers,Install"
    [[ "$DO_PLUGINS"     == true ]] && rows+=$'\n'"Hyprland Plugins,Install"
    [[ "$DO_FINGERPRINT" == true ]] && rows+=$'\n'"Fingerprint,Enroll"
    [[ "$DO_HOWDY"       == true ]] && rows+=$'\n'"Howdy,Enroll"
    [[ "$DO_THINKFAN"    == true ]] && rows+=$'\n'"Thinkfan,Configure"
    [[ "$DO_EASYEFFECTS" == true ]] && rows+=$'\n'"EasyEffects,Install"
    [[ "$DO_WAYDROID"    == true ]] && rows+=$'\n'"Waydroid,Install"
    [[ "$DO_WALLPAPERS"  == true ]] && rows+=$'\n'"Wallpapers,Clone"
    [[ "$DO_SPICETIFY"   == true ]] && rows+=$'\n'"Spicetify,Apply"
    [[ "$DO_SSH"         == true ]] && rows+=$'\n'"SSH Key,$SSH_EMAIL"

    if [[ "$rows" == "Step,Action" ]]; then
        gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
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

while true; do
    run_selection
    collect_inputs
    show_summary

    if gum confirm "Run it" --affirmative="Yes" --negative="Change it"; then
        break
    else
        gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
            "  Starting over..."
        sleep 1
    fi
done

# =============================================================================
# PHASE 4 — EXECUTE
# =============================================================================

# Count total steps
TOTAL=0
[[ "$DO_EXTRA"       == true ]] && (( TOTAL++ ))
[[ "$DO_GIT"         == true ]] && (( TOTAL++ ))
[[ "$DO_GPU"         == true ]] && (( TOTAL++ ))
[[ "$DO_PLUGINS"     == true ]] && (( TOTAL++ ))
[[ "$DO_FINGERPRINT" == true ]] && (( TOTAL++ ))
[[ "$DO_HOWDY"       == true ]] && (( TOTAL++ ))
[[ "$DO_THINKFAN"    == true ]] && (( TOTAL++ ))
[[ "$DO_EASYEFFECTS" == true ]] && (( TOTAL++ ))
[[ "$DO_WAYDROID"    == true ]] && (( TOTAL++ ))
[[ "$DO_WALLPAPERS"  == true ]] && (( TOTAL++ ))
[[ "$DO_SPICETIFY"   == true ]] && (( TOTAL++ ))
[[ "$DO_SSH"         == true ]] && (( TOTAL++ ))

STEP=0
NEEDS_REBOOT=false

step_header() {
    (( STEP++ ))
    echo ""
    gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
        "  [$STEP/$TOTAL] $1"
}

show_screen
gum style --foreground "$C_PRIMARY" --padding "0 0 0 $PADDING_LEFT" \
    "  Executing..."
echo ""

START_TIME=$SECONDS

[[ "$DO_EXTRA" == true ]] && {
    step_header "Extra Packages"
    bash "$INSTALL_DIR/packaging/packages" extra && mark_done "extra-packages" || warn "Extra packages had errors"
}

[[ "$DO_GIT" == true ]] && {
    step_header "Git Identity"
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    mark_done "git"
    ok "Git identity set"
}

[[ "$DO_GPU" == true ]] && {
    step_header "GPU Drivers"
    run_step "extras/gpu-driver.sh" "GPU Drivers" false "$LOG_FILE"
    mark_done "gpu-drivers"
    NEEDS_REBOOT=true
}

[[ "$DO_PLUGINS" == true ]] && {
    step_header "Hyprland Plugins"
    run_step "extras/plugins.sh" "Hyprland Plugins" false "$LOG_FILE"
    mark_done "hyprland-plugins"
    NEEDS_REBOOT=true
}

[[ "$DO_FINGERPRINT" == true ]] && {
    step_header "Fingerprint"
    fprintd-enroll && mark_done "fingerprint" && ok "Fingerprint enrolled" || warn "Fingerprint had errors"
}

[[ "$DO_HOWDY" == true ]] && {
    step_header "Howdy"
    run_step "extras/howdy.sh" "Howdy" false "$LOG_FILE"
    mark_done "howdy"
}

[[ "$DO_THINKFAN" == true ]] && {
    step_header "Thinkfan"
    run_step "extras/thinkfan.sh" "Thinkfan" false "$LOG_FILE"
    mark_done "thinkfan"
}

[[ "$DO_EASYEFFECTS" == true ]] && {
    step_header "EasyEffects"
    run_step "extras/easyeffects.sh" "EasyEffects" false "$LOG_FILE"
    mark_done "easyeffects"
}

[[ "$DO_WAYDROID" == true ]] && {
    step_header "Waydroid"
    run_step "extras/waydroid.sh" "Waydroid" false "$LOG_FILE"
    mark_done "waydroid"
    NEEDS_REBOOT=true
}

[[ "$DO_WALLPAPERS" == true ]] && {
    step_header "Wallpapers"
    run_step "extras/wallpapers.sh" "Wallpapers" false "$LOG_FILE"
    mark_done "wallpapers"
}

[[ "$DO_SPICETIFY" == true ]] && {
    step_header "Spicetify"
    run_step "extras/spicetify.sh" "Spicetify" false "$LOG_FILE"
    mark_done "spicetify"
}

[[ "$DO_SSH" == true ]] && {
    step_header "SSH Key"
    ssh-keygen -t ed25519 -C "$SSH_EMAIL" -f "$HOME/.ssh/id_ed25519" -N ""
    mark_done "ssh"
    echo ""
    gum style --foreground "$C_TEAL" --padding "0 0 0 $PADDING_LEFT" \
        "  Public key (add to GitHub/GitLab):"
    echo ""
    gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
        "$(cat "$HOME/.ssh/id_ed25519.pub")"
    ok "SSH key generated"
}

# =============================================================================
# DONE
# =============================================================================
DURATION=$(( SECONDS - START_TIME ))
echo ""
gum style --foreground "$C_SUCCESS" --padding "0 0 0 $PADDING_LEFT" \
    "  ✓ Done in ${DURATION}s"

echo ""
gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
    "  Remove the autostart entry when done:" \
    "  ~/.config/hypr/autostart.lua  →  comment out post-install.sh" \
    "" \
    "  Re-run anytime:  bash ~/Archer/post-install.sh" \
    "  Force redo:      rm $STATE_DIR/<step>.done"

if [[ "$NEEDS_REBOOT" == true ]]; then
    echo ""
    gum style --foreground "$C_ACCENT" --padding "0 0 0 $PADDING_LEFT" \
        "  ↻  A reboot is recommended to apply the changes from this session."
fi

echo ""