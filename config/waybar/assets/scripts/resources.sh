#!/bin/bash

# --- CPU Calculation ---
get_cpu() {
    awk '/^cpu / {t=$2+$3+$4+$5+$6+$7+$8; i=$5; print t","i}' /proc/stat
}

IFS=',' read -r t1 i1 <<< "$(get_cpu)"
sleep 0.5
IFS=',' read -r t2 i2 <<< "$(get_cpu)"

dt=$((t2 - t1))
di=$((i2 - i1))

if (( dt == 0 )); then
    cpu_usage=0
else
    cpu_usage=$(( (100 * (dt - di)) / dt ))
fi

if   (( cpu_usage < 13 )); then cpu_icon="󰪞"
elif (( cpu_usage < 25 )); then cpu_icon="󰪟"
elif (( cpu_usage < 38 )); then cpu_icon="󰪠"
elif (( cpu_usage < 50 )); then cpu_icon="󰪡"
elif (( cpu_usage < 63 )); then cpu_icon="󰪢"
elif (( cpu_usage < 75 )); then cpu_icon="󰪣"
elif (( cpu_usage < 88 )); then cpu_icon="󰪤"
else cpu_icon="󰪥"
fi

# --- RAM Calculation (GB Output) ---
# Grabs values natively in KB
read -r total avail <<< "$(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2; print t" "a}' /proc/meminfo)"

if [[ -z "$total" || -z "$avail" || "$total" -eq 0 ]]; then
    ram_pct=0
    ram_string="0.0G"
else
    # Calculate percentage layout purely to pick your custom M3 scale icons
    ram_pct=$(( (100 * (total - avail)) / total ))
    
    # Calculate human-readable used GB using awk floating precision
    ram_string=$(awk -v t="$total" -v a="$avail" 'BEGIN { printf "%.1fG", (t - a) / 1024 / 1024 }')
fi

# Determine RAM Icon based on capacity tiers[cite: 5]
if   (( ram_pct < 17 )); then ram_icon="󰋙"
elif (( ram_pct < 34 )); then ram_icon="󰫃"
elif (( ram_pct < 50 )); then ram_icon="󰫄"
elif (( ram_pct < 67 )); then ram_icon="󰫅"
elif (( ram_pct < 84 )); then ram_icon="󰫆"
else ram_icon="󰋘"
fi

# --- Formatted Outputs ---
# Main Bar Text (Swapped ram_pct for ram_string)
text="<span size='18000'>$cpu_icon $ram_icon</span>"

# Hover Tooltip Text
tooltip=" CPU Load: $cpu_usage%\n  RAM Usage: $ram_string ($ram_pct%)"

# Safe JSON string escaping for Waybar
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"