# Waybar (Archer)

Waybar is Archer's status bar (Omarchy uses Quickshell/omarchy-shell; Archer uses Waybar).

- Live config: `~/.config/waybar/config.jsonc` + `style.css`
- Repo source: `~/Archer/config/waybar/`
- Reload: `restart-waybar` or `systemctl --user restart waybar` (or `omarchy restart waybar` if wrapped)
- Reset: `refresh-waybar`

Edit the repo, not the live `~/.config/` copy directly — `update.sh` overwrites it.
