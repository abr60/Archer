#!/usr/bin/env bash
# =============================================================================
# services/user-services.sh — Enable required user-level systemd services 
#systemctl --user enable --now orbit
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "User Services"

declare -a ENABLED=()
declare -a SKIPPED=()
declare -a MISSING=()
declare -a FAILED=()

_enable() {
    local svc="$1"
    if ! unit_exists_user "$svc"; then
        warn "$svc (user) not found — skipping"
        MISSING+=("$svc")
        return
    fi
    if is_enabled_user "$svc"; then
        ok "$svc already enabled"
        SKIPPED+=("$svc")
        return
    fi
    if systemctl --user enable --now "$svc"; then
        ok "Enabled $svc"
        ENABLED+=("$svc")
    else
        warn "Failed to enable $svc"
        FAILED+=("$svc")
    fi
}

systemctl --user daemon-reload

_enable mpd.service
_enable mpd-mpris.service
_enable swayosd-server.service
_enable battery-monitor.timer
_enable recover-internal-monitor.service

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
[[ ${#ENABLED[@]}  -gt 0 ]] && echo -e "${GREEN} ✓ Enabled  (${#ENABLED[@]}):${NC}  ${ENABLED[*]}"
[[ ${#SKIPPED[@]}  -gt 0 ]] && echo -e "${YELLOW} ! Skipped  (${#SKIPPED[@]}):${NC}  ${SKIPPED[*]}"
[[ ${#MISSING[@]}  -gt 0 ]] && echo -e "${YELLOW} ! Missing  (${#MISSING[@]}):${NC}  ${MISSING[*]}"
[[ ${#FAILED[@]}   -gt 0 ]] && echo -e "${RED} ✗ Failed   (${#FAILED[@]}):${NC}  ${FAILED[*]}"

[[ ${#FAILED[@]} -gt 0 ]] && warn "Some services failed — check output above"
