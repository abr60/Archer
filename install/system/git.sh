#!/usr/bin/env bash
# =============================================================================
# system/git.sh — Configure git user name and email
# Skips if already configured, prompts interactively if not
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "Git Configuration"

CURRENT_NAME=$(git config --global user.name 2>/dev/null || true)
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [[ -n "$CURRENT_NAME" && -n "$CURRENT_EMAIL" ]]; then
    ok "Git already configured:"
    ok "  Name  : $CURRENT_NAME"
    ok "  Email : $CURRENT_EMAIL"

    if ! ask_yes_no "Update git config?"; then
        exit 0
    fi
fi

# Get name
GIT_NAME=$(gum_input "Your full name (for git commits)")
if [[ -n "$GIT_NAME" ]]; then
    git config --global user.name "$GIT_NAME"
    ok "Set git user.name: $GIT_NAME"
else
    warn "No name entered — skipping"
fi

# Get email
GIT_EMAIL=$(gum_input "Your email (for git commits)")
if [[ -n "$GIT_EMAIL" ]]; then
    git config --global user.email "$GIT_EMAIL"
    ok "Set git user.email: $GIT_EMAIL"
else
    warn "No email entered — skipping"
fi

# Sensible defaults
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input

ok "Git configuration complete"
