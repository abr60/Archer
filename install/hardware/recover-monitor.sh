#!/usr/bin/env bash
# =============================================================================
# hardware/recover-monitor.sh — Enable internal monitor recovery service
# Recovers the internal display if it gets toggled off when lid is opened
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Monitor Recovery Service"

systemctl --user daemon-reload
enable_user_service recover-internal-monitor.service
