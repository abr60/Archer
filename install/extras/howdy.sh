#!/usr/bin/env bash
# =============================================================================
# extras/howdy.sh — Set up Howdy face recognition for ThinkPad T14 Gen 2i
#
# Auth order configured:
#   Graphical (hyprlock/sddm): howdy → fingerprint → password
#   Terminal (sudo):           howdy → password → fingerprint
#
# Requires: howdy-next-git, linux-enable-ir-emitter-bin
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Howdy Face Recognition Setup"

# ─── Guard ────────────────────────────────────────────────────────────────────
if ! is_installed howdy-next-git; then
    warn "howdy-next-git not installed — skipping"
    exit 0
fi

if ! is_installed linux-enable-ir-emitter-bin; then
    warn "linux-enable-ir-emitter-bin not installed — skipping"
    exit 0
fi

# ─── Detect IR camera ─────────────────────────────────────────────────────────
section "IR Camera Detection"

IR_DEVICE=""
IR_PATH="/dev/v4l/by-path/pci-0000:00:14.0-usb-0:4:1.2-video-index0"

# Verify the by-path symlink exists and resolves to a GREY camera
if [[ -e "$IR_PATH" ]]; then
    FORMAT=$(v4l2-ctl --device="$IR_PATH" --list-formats 2>/dev/null | grep -i grey || true)
    if [[ -n "$FORMAT" ]]; then
        IR_DEVICE="$IR_PATH"
        ok "IR camera confirmed: $IR_DEVICE"
    fi
fi

# Fallback: scan all video devices for greyscale output
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
        # Grant root display access for GTK window
        xhost +si:localuser:root 2>/dev/null || true

        sudo linux-enable-ir-emitter configure
        leire_exit=$?
        if [[ $leire_exit -eq 0 || $leire_exit -eq 2 ]]; then
            ok "IR emitter configured (or already working)"
        else
            warn "Configuration failed — continuing anyway"
        fi

        # Revoke display access
        xhost -si:localuser:root 2>/dev/null || true
    else
        warn "Skipping IR emitter configuration — Howdy may not work"
        warn "Run manually: xhost +si:localuser:root && sudo linux-enable-ir-emitter configure"
    fi
fi

# Enable and start the service
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

# Backup existing config
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
timeout = 8
device_path = $IR_DEVICE
warn_no_device = true
max_height = 240
frame_width = 320
frame_height = 320
dark_threshold = 50
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

# ─── PAM Configuration ────────────────────────────────────────────────────────
section "PAM Configuration"

# sudo — howdy → password → fingerprint
msg "Configuring PAM for sudo..."
sudo tee /etc/pam.d/sudo > /dev/null << 'PAMEOF'
#%PAM-1.0
# howdy → password → fingerprint
#%PAM-1.0
auth       sufficient   pam_howdy.so
auth       include      system-auth

auth       sufficient   pam_fprintd.so
auth       required     pam_deny.so

account    required     pam_unix.so
session    required     pam_unix.so
PAMEOF
ok "sudo PAM: howdy → password → fingerprint"

# hyprlock — howdy → fingerprint → password
msg "Configuring PAM for hyprlock..."
sudo tee /etc/pam.d/hyprlock > /dev/null << 'PAMEOF'
#%PAM-1.0
# howdy → fingerprint → password
# TODO: hyprlock PAM — needs further investigation
# pam_howdy.so workaround options don't work reliably with hyprlock yet
# Current workaround: use fingerprint or password at hyprlock
warn "hyprlock howdy integration pending — skipping for now"
PAMEOF
ok "hyprlock PAM: howdy → fingerprint → password"

# sddm — howdy → fingerprint → password
msg "Configuring PAM for sddm..."
sudo tee /etc/pam.d/sddm > /dev/null << 'PAMEOF'
#%PAM-1.0
# howdy → fingerprint → password
#%PAM-1.0
auth       sufficient   pam_howdy.so
auth       sufficient   pam_fprintd.so
auth       sufficient   pam_unix.so try_first_pass nullok
auth       required     pam_deny.so

account    include      system-login
session    include      system-login
PAMEOF
ok "sddm PAM: howdy → fingerprint → password"

# ─── Clear old face models and enroll fresh ───────────────────────────────────
section "Face Model Enrollment"

HOWDY_MODELS="/etc/howdy/models"
sudo mkdir -p "$HOWDY_MODELS"

# Remove any existing models for clean slate
if [[ -n "$(sudo ls -A "$HOWDY_MODELS" 2>/dev/null)" ]]; then
    msg "Removing existing face models for fresh enrollment..."
    sudo howdy clear -y 2>/dev/null || sudo rm -f "$HOWDY_MODELS"/*.dat 2>/dev/null || true
    ok "Old models cleared"
fi

# Enroll face
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

# ─── Summary ──────────────────────────────────────────────────────────────────
section "Howdy Setup Complete"
ok "IR camera       : $IR_DEVICE"
ok "Models          : $MODELS_DIR"
ok "Config          : /etc/howdy/config.ini"
ok "PAM sudo        : howdy → password → fingerprint"
ok "PAM hyprlock    : howdy → fingerprint → password"
ok "PAM sddm        : howdy → fingerprint → password"
echo ""
warn "If face recognition fails: sudo howdy test"
warn "To re-enroll: sudo howdy clear -y && sudo howdy add"