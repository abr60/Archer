#!/usr/bin/env bash
# =============================================================================
# Archer - Post-Install Wizard
# Runs automatically on first login via autostart.lua.
# Phase 1: Select  — one multi-select screen, space to toggle
# Phase 2: Input   — collect extra details for selected steps
# Phase 3: Confirm — summary table, loop back if rejected
# Phase 4: Execute — run in order
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
# INTRO SCREEN
# =============================================================================
show_screen

gum style \
    --foreground "$C_PRIMARY" \
    --padding "0 0 0 $PADDING_LEFT" \
    "  Archer Post-Install" \
    "  Select what you want to set up. Space to toggle, enter to confirm." \
    "  Completed steps are hidden. Nothing runs until you confirm."

echo ""
gum confirm "Ready?" || { msg "Aborted. Run ~/Archer/post-install.sh anytime."; exit 0; }

# =============================================================================
# PHASE 1 — MULTI-SELECT
# =============================================================================

# Build list of pending steps (skip already-done ones)
build_options() {
    OPTIONS=()
    ! is_done "extra-packages"    && OPTIONS+=("Extra Packages")
    ! is_done "git"               && OPTIONS+=("Git Identity")
    ! is_done "gpu-drivers"       && OPTIONS+=("GPU Drivers")
    ! is_done "hyprland-plugins"  && OPTIONS+=("Hyprland Plugins")
    is_laptop && ! is_done "fingerprint" && OPTIONS+=("Fingerprint")
    ! is_done "howdy"             && OPTIONS+=("Howdy")
    is_thinkpad && ! is_done "thinkfan"     && OPTIONS+=("Thinkfan")
    is_thinkpad && ! is_done "easyeffects"  && OPTIONS+=("EasyEffects")
    ! is_done "waydroid"          && OPTIONS+=("Waydroid")
    ! is_done "wallpapers"        && OPTIONS+=("Wallpapers")
    ! is_done "spicetify"         && OPTIONS+=("Spicetify")
    ! is_done "ssh"               && OPTIONS+=("SSH Key")
}

run_selection() {
    build_options

    if [[ ${#OPTIONS[@]} -eq 0 ]]; then
        gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
            "  Nothing left to do — all steps are marked done."
        exit 0
    fi

    show_screen

    SELECTED=$(printf '%s\n' "${OPTIONS[@]}" | gum choose \
        --no-limit \
        --cursor "▶ " \
        --cursor-prefix "● " \
        --selected-prefix "● " \
        --unselected-prefix "○ " \
        --header "  Select steps to run  (space to toggle, enter to confirm)" \
        --header.foreground "$C_PRIMARY" \
        --cursor.foreground "$C_ACCENT" \
        --selected.foreground "$C_ACCENT")

    echo ""
}

# =============================================================================
# PHASE 2 — COLLECT EXTRA INPUT FOR SELECTED STEPS
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

    grep -q "Extra Packages"    <<< "$SELECTED" && DO_EXTRA=true
    grep -q "GPU Drivers"       <<< "$SELECTED" && DO_GPU=true
    grep -q "Hyprland Plugins"  <<< "$SELECTED" && DO_PLUGINS=true
    grep -q "Fingerprint"       <<< "$SELECTED" && DO_FINGERPRINT=true
    grep -q "Howdy"             <<< "$SELECTED" && DO_HOWDY=true
    grep -q "Thinkfan"          <<< "$SELECTED" && DO_THINKFAN=true
    grep -q "EasyEffects"       <<< "$SELECTED" && DO_EASYEFFECTS=true
    grep -q "Waydroid"          <<< "$SELECTED" && DO_WAYDROID=true
    grep -q "Wallpapers"        <<< "$SELECTED" && DO_WALLPAPERS=true
    grep -q "Spicetify"         <<< "$SELECTED" && DO_SPICETIFY=true

    if grep -q "Git Identity" <<< "$SELECTED"; then
        DO_GIT=true
        show_screen
        gum style --foreground "$C_PRIMARY" --padding "0 0 0 $PADDING_LEFT" \
            "  Git Identity"
        echo ""
        GIT_NAME=$(gum input --placeholder "Your Name")
        GIT_EMAIL=$(gum input --placeholder "your@email.com")
        echo ""
    fi

    if grep -q "SSH Key" <<< "$SELECTED"; then
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
# PHASE 3 — SUMMARY TABLE + CONFIRM LOOP
# =============================================================================

show_summary() {
    show_screen
    gum style --foreground "$C_ACCENT" --padding "0 0 0 $PADDING_LEFT" \
        "  Review — does this look right?"
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
show_screen
gum style --foreground "$C_ACCENT" --padding "0 0 0 $PADDING_LEFT" \
    "  Executing..."
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
    run_step "extras/spicetify.sh" "Spicetify" false "$LOG_FILE"
    mark_done "spicetify"
}

[[ "$DO_SSH" == true ]] && {
    section "SSH Key"
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
gum style --foreground "$C_ERROR" --padding "0 0 0 $PADDING_LEFT" \
    "  Remove the autostart entry when done:" \
    "  ~/.config/hypr/autostart.lua  →  comment out post-install.sh"

echo ""
gum style --foreground "$C_MUTED" --padding "0 0 0 $PADDING_LEFT" \
    "  Re-run anytime:  bash ~/Archer/post-install.sh" \
    "  Force redo:      rm $STATE_DIR/<step>.done"

echo ""
gum confirm "Reboot now?" && sudo reboot || msg "Reboot skipped."