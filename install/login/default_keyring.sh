#!/usr/bin/env bash

# ==============================================================================
# Script Name: default_keyring.sh
# Location:    .../login/default_keyring.sh
# Description: Automates the clean initialization of the GNOME Keyring structure
#              to enable silent unlocking out-of-the-box on a fresh installation.
# ==============================================================================

set -euo pipefail

# Define target paths
KEYRING_DIR="$HOME/.local/share/keyrings"
KEYRING_FILE="$KEYRING_DIR/Default_keyring.keyring"
DEFAULT_FILE="$KEYRING_DIR/default"

echo "Initializing GNOME Keyring template structure..."

# Ensure the parent keyrings directory exists
mkdir -p "$KEYRING_DIR"

# Generate the Default keyring metadata template
cat << EOF > "$KEYRING_FILE"
[keyring]
display-name=Default keyring
ctime=$(date +%s)
mtime=0
lock-on-idle=false
lock-after=false
EOF

# Direct the keyring manager to target the custom template by default
echo "Default_keyring" > "$DEFAULT_FILE"

# Enforce secure Linux file permissions required by the keyring daemon
chmod 700 "$KEYRING_DIR"
chmod 600 "$KEYRING_FILE"
chmod 644 "$DEFAULT_FILE"

echo "GNOME Keyring initialized successfully with correct permissions."