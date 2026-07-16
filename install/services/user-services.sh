#!/usr/bin/env bash
# =============================================================================
# services/user-services.sh — Enable required user-level systemd services
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "User Services"

# Ensure MPD local state directories exist before running service
if [ ! -d "$HOME/.local/share/mpd/playlists" ]; then
    mkdir -p "$HOME/.local/share/mpd/playlists"
    ok "Created MPD playlist directory"
fi

systemctl --user daemon-reload

enable_user_service swayosd-server.service
enable_user_service recover-internal-monitor.service
enable_user_service mpd.service
enable_user_service mpd-mpris.service

# Force MPD to create/refresh database file cleanly if running
if systemctl --user is-active mpd.service &>/dev/null; then
    mpc update &>/dev/null || true
fi