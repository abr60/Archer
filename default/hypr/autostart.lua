-- Archer default autostart processes.
-- Services (swayosd, mpd etc.) are managed by systemd — see services/user-services.sh
-- Only launch processes here that aren't managed by systemd.

-- Core UI
a.exec_on_start("uwsm app -- waybar")
a.exec_on_start("uwsm app -- swaync")
a.exec_on_start("uwsm app -- awww-daemon")
a.exec_on_start("uwsm app -- hyprland-monitor-watch")
a.launch_on_start("hypridle")

-- Auth agent (hyprpolkitagent handles this via systemd, fallback below if needed)
a.exec_on_start("systemctl --user start hyprpolkitagent")

-- Plugin reload
a.exec_on_start("hyprpm reload")

-- Clipboard history
a.exec_on_start("wl-paste --type text --watch cliphist store")
a.exec_on_start("wl-paste --type image --watch cliphist store")