#!/usr/bin/env bash
# Path: ~/.config/hypr/scripts/whatsapp_call.sh

if [ "$1" = "answer" ]; then
    # Optional: Wait a brief moment for focus to lock
    sleep 0.1
    
    # Use ydotool or wooting to trigger a mouse click over the green answer slider area 
    # Or simulate Tab navigation if your wrapper supports keyboard navigation to the banner
    # Alternative: use wtype to send the browser-specific notification click sequence
    wtype -k Return
fi