#!/bin/bash
STATE_FILE="$HOME/.local/state/Archer/mpris-last-player"
mkdir -p "$(dirname "$STATE_FILE")"

priority=(mpd spotify chromium firefox mpv)
last_player=$(cat "$STATE_FILE" 2>/dev/null)

# Check if any player is actively Playing
for p in "${priority[@]}"; do
  s=$(playerctl -p "$p" status 2>/dev/null)
  if [[ "$s" == "Playing" ]]; then
    player="$p"
    status="$s"
    title=$(playerctl -p "$p" metadata title 2>/dev/null)
    echo "$player" > "$STATE_FILE"
    break
  fi
done

# Nothing playing — fall back to last known player's current state
if [[ -z "$status" && -n "$last_player" ]]; then
  s=$(playerctl -p "$last_player" status 2>/dev/null)
  t=$(playerctl -p "$last_player" metadata title 2>/dev/null)
  if [[ -n "$t" ]]; then
    player="$last_player"
    status="$s"
    title="$t"
  fi
fi

[[ -z "$title" ]] && { echo '{"text":"No media","tooltip":"","class":"none"}'; exit; }

max=24
if (( ${#title} > max )); then
    title="${title:0:$max}"
fi

case "$player" in
  mpd) icon="󰎆" ;;
  chromium) icon="" ;;
  spotify) icon="" ;;
  firefox) icon="" ;;
  mpv) icon="󰎁" ;;
  *) icon="󰎆" ;;
esac

if [[ "$status" == "Playing" ]]; then
  class="playing"
else
  icon="󰫔"
  class="paused"
fi

echo "{\"text\":\"<span size='18000' baseline_shift='-4000'>$icon</span> \",\"class\":\"$class\"}"