#!/bin/bash
MAXLEN=20

player_name=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)
player_status=$(playerctl status 2>/dev/null)
title=$(playerctl metadata xesam:title 2>/dev/null)
artist=$(playerctl metadata xesam:artist 2>/dev/null)

# Strip Spotify's garbage suffixes like "(with ...)" and "- From The..."
title=$(echo "$title" | sed 's/ (with.*//; s/ - .*//')

if [ ${#title} -gt $MAXLEN ]; then
    title="${title:0:$MAXLEN}…"
fi

case "$player_name" in
    spotify)  ICON="󰓇" ;;
    firefox)  ICON="󰈹" ;;
    mpd)      ICON="󰎆" ;;
    chromium) ICON="󰊯" ;;
    *)        ICON="󰝚" ;;
esac

case "$player_status" in
    Playing) echo "$ICON  $title · $artist" ;;
    Paused)  echo "󰏤  Paused" ;;
    *)       echo "󰝛  No media" ;;
esac