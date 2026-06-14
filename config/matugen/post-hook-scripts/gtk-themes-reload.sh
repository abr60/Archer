#!/usr/bin/env bash
# Force GTK3 theme reload
gsettings set org.gnome.desktop.interface gtk-theme ""
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"

# Force GTK4 theme reload
gsettings set org.gnome.desktop.interface color-scheme prefer-light
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Only restart Nautilus if it was running
#if pgrep -x nautilus &>/dev/null; then
 #   nautilus -q
  #  sleep 0.3
   # nohup nautilus --no-default-window &>/dev/null &
#fi

nautilus -q && nautilus &