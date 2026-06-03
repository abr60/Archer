#!/bin/bash
LOCATION="Chattogram"  # or leave empty for auto-detect by IP

WEATHER=$(curl -sf "https://wttr.in/${LOCATION}?format=%c+%t" 2>/dev/null)

if [ -z "$WEATHER" ]; then
    echo "󰖑  --"
    exit 0
fi

echo "$WEATHER"