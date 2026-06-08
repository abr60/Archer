#!/usr/bin/env bash
# =============================================================================
# system/input-group.sh — Add user to input group
# Required for dictation tools, Xbox controllers, and other input devices
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Input Group"

if groups "$USER" | grep -q '\binput\b'; then
    ok "User $USER already in input group — skipping"
    exit 0
fi

sudo usermod -aG input "$USER"
ok "Added $USER to input group"
warn "Log out and back in for group change to take effect"
