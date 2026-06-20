#!/usr/bin/env bash
# =============================================================================
# services/user-services.sh — Enable required user-level systemd services
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "User Services"

systemctl --user daemon-reload

enable_user_service swayosd-server.service
enable_user_service recover-internal-monitor.service
enable_user_service mpd.service
enable_user_service mpd-mpris.service