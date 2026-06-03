#!/bin/bash
IFACE="wlan0"

SIGNAL=$(iw dev "$IFACE" link 2>/dev/null | awk '/signal:/{print $2}')

if [ -z "$SIGNAL" ]; then
    echo "󰖪"
    exit 0
fi

SIGNAL_PCT=$(awk "BEGIN {v=$SIGNAL; if(v<=-90) print 0; else if(v>=-30) print 100; else printf \"%d\", (v+90)*100/60}")

if [ "$SIGNAL_PCT" -ge 75 ]; then ICON=" "
elif [ "$SIGNAL_PCT" -ge 50 ]; then ICON="  "
elif [ "$SIGNAL_PCT" -ge 25 ]; then ICON=" "
else ICON=" "
fi

echo "$ICON"