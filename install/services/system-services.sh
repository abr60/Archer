#!/usr/bin/env bash
# =============================================================================
# services/system-services.sh — Enable required system-level services
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "System Services"

enable_system_service NetworkManager.service
enable_system_service NetworkManager-dispatcher.service
enable_system_service bluetooth.service
enable_system_service thinkfan.service
enable_system_service ufw.service
enable_system_service sddm.service
enable_system_service power-profiles-daemon.service
#enable_system_service linux-enable-ir-emitter.service