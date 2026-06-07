#!/usr/bin/env bash
# =============================================================================
# system/sudo-tries.sh — Allow 10 password attempts before lockout
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Sudo Password Tries"

if [[ -f /etc/sudoers.d/passwd-tries ]]; then
    ok "sudo-tries already configured — skipping"
    exit 0
fi

echo "Defaults passwd_tries=10" | sudo tee /etc/sudoers.d/passwd-tries > /dev/null
sudo chmod 440 /etc/sudoers.d/passwd-tries

# Set for hyprlock too
sudo sed -i 's/^# *deny = .*/deny = 10/' /etc/security/faillock.conf 2>/dev/null || true

ok "Password tries set to 10 before lockout"
