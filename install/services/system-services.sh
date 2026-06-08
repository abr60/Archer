#!/usr/bin/env bash
# =============================================================================
# services/system-services.sh — Enable required system-level services
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "System Services"

declare -a ENABLED=()
declare -a SKIPPED=()
declare -a MISSING=()
declare -a FAILED=()

_enable() {
    local svc="$1"
    if ! unit_exists_system "$svc"; then
        warn "$svc not found — skipping"
        MISSING+=("$svc")
        return
    fi
    if is_enabled_system "$svc"; then
        ok "$svc already enabled"
        SKIPPED+=("$svc")
        return
    fi
    if sudo systemctl enable --now "$svc"; then
        ok "Enabled $svc"
        ENABLED+=("$svc")
    else
        warn "Failed to enable $svc"
        FAILED+=("$svc")
    fi
}

_enable NetworkManager.service
_enable NetworkManager-dispatcher.service
_enable bluetooth.service
_enable tlp.service
_enable thinkfan.service
_enable ufw.service
_enable sddm.service
_enable linux-enable-ir-emitter.service

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
[[ ${#ENABLED[@]}  -gt 0 ]] && echo -e "${GREEN} ✓ Enabled  (${#ENABLED[@]}):${NC}  ${ENABLED[*]}"
[[ ${#SKIPPED[@]}  -gt 0 ]] && echo -e "${YELLOW} ! Skipped  (${#SKIPPED[@]}):${NC}  ${SKIPPED[*]}"
[[ ${#MISSING[@]}  -gt 0 ]] && echo -e "${YELLOW} ! Missing  (${#MISSING[@]}):${NC}  ${MISSING[*]}"
[[ ${#FAILED[@]}   -gt 0 ]] && echo -e "${RED} ✗ Failed   (${#FAILED[@]}):${NC}  ${FAILED[*]}"

[[ ${#FAILED[@]} -gt 0 ]] && warn "Some services failed — check output above"
