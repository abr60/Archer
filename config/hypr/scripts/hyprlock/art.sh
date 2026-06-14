#!/usr/bin/bash
mkdir -p ~/.cache/albumart

url=$(playerctl metadata mpris:artUrl 2>/dev/null)
artist=$(playerctl metadata xesam:artist 2>/dev/null)
album=$(playerctl metadata xesam:album 2>/dev/null)
metadata=$(printf "$artist - $album")

if [ -z "$url" ] || [ "$url" == "No player found" ]; then
    exit
elif [ -f ~/.cache/albumart/"$metadata".png ]; then
    echo ~/.cache/albumart/"$metadata".png
else
    curl -s "$url" -o ~/.cache/albumart/"$metadata"
    magick ~/.cache/albumart/"$metadata" ~/.cache/albumart/"$metadata".png
    rm ~/.cache/albumart/"$metadata"
    echo ~/.cache/albumart/"$metadata".png
fi