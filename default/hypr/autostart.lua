-- Archer default autostart processes.
-- Services (swayosd, mpd etc.) are managed by systemd — see services/user-services.sh
-- Only launch processes here that aren't managed by systemd.

-- 1. Environment Variables (CRITICAL: Must run first)
a.exec_on_start("systemctl --user import-environment $(env | cut -d'=' -f 1)")
a.exec_on_start("dbus-update-activation-environment --systemd --all")

-- 2. Authentication Agent
a.exec_on_start("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")

-- 3. Visual Baseline & Wallpaper
a.exec_on_start("uwsm app -- awww-daemon")
--a.launch_on_start("swaybg -i ~/.local/state/Archer/current-wallpaper -m fill")
a.exec_on_start("hyprsunset")

-- 4. Core UI Components
a.exec_on_start("uwsm app -- hyprland-monitor-watch")
a.exec_on_start("! toggle-enabled waybar-off && " .. a.launch("waybar"))
a.exec_on_start("uwsm app -- swaync")

-- 5. Background Services & Idling
a.launch_on_start("hypridle")
a.exec_on_start("wl-paste --type text --watch cliphist store")
a.exec_on_start("wl-paste --type image --watch cliphist store")