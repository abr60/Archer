#!/usr/bin/env bash
# =============================================================================
# system/file-watchers.sh — Increase inotify file watchers
# Default of 8192 is too low for VSCode, webpack, and other dev tools
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "File Watchers"

CONF="/etc/sysctl.d/90-archer-file-watchers.conf"

if [[ -f "$CONF" ]]; then
    ok "File watchers already configured — skipping"
    exit 0
fi

echo "fs.inotify.max_user_watches=524288" | sudo tee "$CONF" > /dev/null
sudo sysctl --system > /dev/null 2>&1

ok "inotify max_user_watches set to 524288"
