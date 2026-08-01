#!/usr/bin/env bash

case "$1" in
    "speedtest")
        notify-send -u low "Network Speedtest" "Running test via speedtest-cli..."
        # Requires speedtest-cli or speedtest (install via pacman -S speedtest-cli)
        if command -v speedtest-cli &> /dev/null; then
            RESULT=$(speedtest-cli --simple)
            notify-send -u normal "Speedtest Results" "$RESULT"
        else
            notify-send -u critical "Error" "speedtest-cli is not installed."
        fi
        ;;
    "info")
        IFACE=$(ip route show default | awk '/default/ {print $5}' | head -n 1)
        IP_PRIV=$(ip addr show "$IFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        IP_PUB=$(curl -s --max-time 3 https://api.ipify.org || echo "Unavailable")
        GATEWAY=$(ip route show default | awk '/default/ {print $3}')
        
        MSG="Interface: $IFACE\nLocal IP: $IP_PRIV\nPublic IP: $IP_PUB\nGateway: $GATEWAY"
        notify-send -u normal "Network Info" "$MSG"
        ;;
esac