#!/usr/bin/env bash
# =============================================================================
# system/mimetypes.sh — Set default applications for file types
# =============================================================================

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"

section "MIME Type Defaults"

# Update desktop database first
update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true

# Browser — Brave
xdg-settings set default-web-browser brave-browser.desktop 2>/dev/null || \
xdg-settings set default-web-browser chromium.desktop 2>/dev/null || true
xdg-mime default brave-browser.desktop x-scheme-handler/http  2>/dev/null || true
xdg-mime default brave-browser.desktop x-scheme-handler/https 2>/dev/null || true
ok "Default browser: Brave"

# File manager — Nautilus
xdg-mime default org.gnome.Nautilus.desktop inode/directory
ok "Default file manager: Nautilus"

# Images — imv
for mime in image/png image/jpeg image/gif image/webp image/bmp image/tiff image/svg+xml; do
    xdg-mime default imv.desktop "$mime" 2>/dev/null || true
done
ok "Default image viewer: imv"

# Video — mpv
for mime in video/mp4 video/x-msvideo video/x-matroska video/x-flv \
            video/x-ms-wmv video/mpeg video/ogg video/webm \
            video/quicktime video/3gpp video/3gpp2; do
    xdg-mime default mpv.desktop "$mime" 2>/dev/null || true
done
ok "Default video player: mpv"

# PDF — Sioyek
xdg-mime default sioyek.desktop application/pdf 2>/dev/null || \
xdg-mime default org.gnome.Evince.desktop application/pdf 2>/dev/null || true
ok "Default PDF viewer: Sioyek"

# Text — VSCode
for mime in text/plain text/english text/x-makefile text/x-c++hdr \
            text/x-c++src text/x-chdr text/x-csrc text/x-java \
            text/x-python application/x-shellscript text/xml application/xml; do
    xdg-mime default code.desktop "$mime" 2>/dev/null || true
done
ok "Default text editor: VSCode"

ok "MIME types configured"
