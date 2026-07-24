#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

THEME_DIR="$HOME/.config/spicetify/Themes/caelestia"
TEMPLATE_DIR="$HOME/.config/matugen/templates"

# 1. Verification
if [[ ! -f "$THEME_DIR/user.css" ]]; then
    echo "Error: user.css is missing in $THEME_DIR"
    exit 1
fi

if [[ ! -f "$TEMPLATE_DIR/spicetify.ini" ]]; then
    echo "Error: spicetify.ini is missing in $TEMPLATE_DIR"
    exit 1
fi

# 2. Permissions
echo "Granting write permissions to Spotify directories..."
sudo chmod a+wr /opt/spotify
sudo chmod a+wr -R /opt/spotify/Apps

# 3. Automation
echo "Initializing Spicetify configuration..."

# Clear any stale or mismatched backups gracefully
spicetify restore backup || true
spicetify clear || true

# Apply target configurations
spicetify config current_theme caelestia color_scheme caelestia inject_css 1 replace_colors 1

# Execute backup and apply the patches
spicetify backup apply

echo "Spicetify pipeline successfully initialized."