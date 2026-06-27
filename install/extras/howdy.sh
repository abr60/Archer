#!/usr/bin/env bash
# =============================================================================
# extras/howdy.sh — Set up Howdy face recognition for ThinkPad T14 Gen 2i
#
# Auth order configured:
#   Graphical (hyprlock/sddm): howdy → fingerprint → password
#   Terminal (sudo):           howdy → password → fingerprint
#
# Requires: howdy-next-git, linux-enable-ir-emitter, xorg-xhost, v4l-utils
# PAM configuration is handled separately by config/pam.sh
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Howdy Face Recognition Setup"

# -----------------------------------------------------------------------------
# Install Howdy and IR emitter packages via the tagged package list
# -----------------------------------------------------------------------------
if ! is_installed howdy-next-git || ! is_installed linux-enable-ir-emitter; then
    bash "$(dirname "${BASH_SOURCE[0]}")/../packaging/packages" extra --tag howdy
fi

# Ensure basic core utilities are present
ensure_installed xorg-xhost
ensure_installed v4l-utils

# ─── Detect IR camera ─────────────────────────────────────────────────────────
section "IR Camera Detection"

IR_DEVICE=""
IR_PATH="/dev/v4l/by-path/pci-0000:00:14.0-usb-0:4:1.2-video-index0"

if [[ -e "$IR_PATH" ]]; then
    FORMAT=$(v4l2-ctl --device="$IR_PATH" --list-formats 2>/dev/null | grep -i grey || true)
    if [[ -n "$FORMAT" ]]; then
        IR_DEVICE="$IR_PATH"
        ok "IR camera confirmed: $IR_DEVICE"
    fi
fi

if [[ -z "$IR_DEVICE" ]]; then
    warn "Stable by-path not found — scanning /dev/video* for IR camera..."
    for dev in /dev/video*; do
        FORMAT=$(v4l2-ctl --device="$dev" --list-formats 2>/dev/null | grep -i grey || true)
        if [[ -n "$FORMAT" ]]; then
            IR_DEVICE="$dev"
            ok "IR camera found at: $IR_DEVICE"
            warn "Consider using by-path symlink for stability"
            break
        fi
    done
fi

if [[ -z "$IR_DEVICE" ]]; then
    err "No IR camera detected — cannot configure Howdy"
    err "Make sure linux-enable-ir-emitter is configured first"
    exit 1
fi

# ─── linux-enable-ir-emitter ──────────────────────────────────────────────────
section "IR Emitter Configuration"

LEIRE_SERVICE="linux-enable-ir-emitter.service"

if systemctl is-active "$LEIRE_SERVICE" &>/dev/null; then
    ok "linux-enable-ir-emitter already active — skipping configuration"
else
    msg "The IR emitter needs to be configured once for your camera."
    msg "This opens an interactive GTK window — needs display access."
    msg "Follow the prompts and look at the camera when asked."
    echo ""

    if ask_yes_no "Configure IR emitter now?"; then
        xhost +si:localuser:root 2>/dev/null || true
        sudo linux-enable-ir-emitter configure
        leire_exit=$?
        if [[ $leire_exit -lt 3 ]]; then
    ok "IR emitter configured (or already working)"
        else
            warn "Configuration failed — continuing anyway"
        fi
        xhost -si:localuser:root 2>/dev/null || true
    else
        warn "Skipping IR emitter configuration — Howdy may not work"
        warn "Run manually: xhost +si:localuser:root && sudo linux-enable-ir-emitter configure"
    fi
fi

sudo systemctl enable --now "$LEIRE_SERVICE" && \
    ok "linux-enable-ir-emitter.service enabled and started" || \
    warn "Failed to enable linux-enable-ir-emitter.service"

# ─── Download ONNX models ─────────────────────────────────────────────────────
section "Howdy ONNX Models"

MODELS_DIR="/usr/share/howdy/models"
YUNET="$MODELS_DIR/face_detection_yunet_2023mar_int8bq.onnx"
SFACE="$MODELS_DIR/face_recognition_sface_2021dec_int8bq.onnx"

if [[ -f "$YUNET" && -f "$SFACE" ]]; then
    ok "ONNX models already present"
else
    msg "Downloading Howdy face models..."
    sudo howdy download-models && ok "Models downloaded" || {
        err "Failed to download models"
        err "Run manually: sudo howdy download-models"
        exit 1
    }
fi

# ─── Write Howdy config ───────────────────────────────────────────────────────
section "Howdy Configuration"

[[ -f /etc/howdy/config.ini ]] && \
    sudo cp /etc/howdy/config.ini /etc/howdy/config.ini.bak && \
    ok "Existing config backed up to /etc/howdy/config.ini.bak"

sudo tee /etc/howdy/config.ini > /dev/null << HOWDYCONF
[core]
detection_notice = false
timeout_notice = true
no_confirmation = true
suppress_unknown = true
abort_if_ssh = true
abort_if_lid_closed = true
disabled = false

[video]
timeout = 5
device_path = $IR_DEVICE
warn_no_device = true
max_height = 240
frame_width = 320
frame_height = 320
dark_threshold = 70
force_mjpeg = false
exposure = -1
device_fps = 0
rotate = 0

[face]
yunet_model = default
sface_model = default
yunet_score_threshold = 0.8845
yunet_nms_threshold = 0.3
yunet_top_k = 1000
sface_metric = cosine
sface_threshold = 0.6942

[snapshots]
save_failed = false
save_successful = false

[debug]
end_report = false
HOWDYCONF

ok "Howdy config written to /etc/howdy/config.ini"

# ─── Face Model Enrollment ────────────────────────────────────────────────────
section "Face Model Enrollment"

HOWDY_MODELS="/etc/howdy/models"
sudo mkdir -p "$HOWDY_MODELS"

if [[ -n "$(sudo ls -A "$HOWDY_MODELS" 2>/dev/null)" ]]; then
    msg "Removing existing face models for fresh enrollment..."
    sudo howdy clear -y 2>/dev/null || sudo rm -f "$HOWDY_MODELS"/*.dat 2>/dev/null || true
    ok "Old models cleared"
fi

msg "Ready to enroll your face."
msg "Look directly at the IR camera when prompted."
echo ""

if ask_yes_no "Enroll your face now?"; then
    sudo howdy add && ok "Face enrolled successfully" || {
        err "Enrollment failed"
        warn "Run manually: sudo howdy add"
    }
    msg "Testing face recognition..."
    sudo howdy test && ok "Face recognition working" || \
        warn "Test failed — check camera position and lighting"
else
    warn "Face enrollment skipped"
    warn "Run manually: sudo howdy add"
fi

# ─── PAM Configuration ────────────────────────────────────────────────────────
section "PAM Configuration"

PAM_SCRIPT="$(dirname "${BASH_SOURCE[0]}")/../config/pam.sh"

if [[ -f "$PAM_SCRIPT" ]]; then
    bash "$PAM_SCRIPT" && ok "PAM configured" || warn "PAM configuration had errors"
else
    warn "pam.sh not found at $PAM_SCRIPT — configure manually"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
section "Howdy Setup Complete"
ok "IR camera  : $IR_DEVICE"
ok "Models     : $MODELS_DIR"
ok "Config     : /etc/howdy/config.ini"
ok "PAM        : configured separately via config/pam.sh"
echo ""
warn "If face recognition fails: sudo howdy test"
warn "To re-enroll: sudo howdy clear -y && sudo howdy add"