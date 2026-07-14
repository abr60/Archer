-- Archer default autostart processes.
-- Services (swayosd, mpd etc.) are managed by systemd — see services/user-services.sh
-- Only launch processes here that aren't managed by systemd.

-- Core UI
a.exec_on_start("! toggle-enabled waybar-off && " .. a.launch("waybar"))
a.exec_on_start("uwsm app -- swaync")
a.exec_on_start("uwsm app -- hyprland-monitor-watch")
a.exec_on_start("hyprsunset")

-- 1. Wallpaper (Switched from triple-w/awww-daemon to swaybg)
--a.launch_on_start("swaybg -i ~/.local/state/Archer/current-wallpaper -m fill")
a.exec_on_start("uwsm app -- awww-daemon")

-- 2. Idling (Ensured hypridle is running)
a.launch_on_start("hypridle")

-- 3. Auth agent (Switched from hyprpolkitagent to polkit-gnome)
a.exec_on_start("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

-- 4. Slow app launch fix (Systemd & DBus environment variables)
a.exec_on_start("systemctl --user import-environment $(env | cut -d'=' -f 1)")
a.exec_on_start("dbus-update-activation-environment --systemd --all")


-- Clipboard history
a.exec_on_start("wl-paste --type text --watch cliphist store")
a.exec_on_start("wl-paste --type image --watch cliphist store")