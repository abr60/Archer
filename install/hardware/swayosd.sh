#!/usr/bin/env bash
# =============================================================================
# hardware/swayosd.sh — Enable SwayOSD server service
# Provides on-screen display for volume/brightness changes
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "SwayOSD"

systemctl --user daemon-reload
enable_user_service swayosd-server.service
