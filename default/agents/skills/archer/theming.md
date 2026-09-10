# Theming (Archer)

- Themes live in `~/Archer/themes/` and `~/.config/omarchy/themes/` / `~/.config/archer/themes/` (user overrides).
- Commands: `theme-set <name>`, `theme-list`, `theme-install`, `theme-bg-set`, `theme-bg-next`, `font-set`, `font-list`.
- `bin/theme-*` and `bin/theme-bg-*` are the source; `bin/omarchy` dispatches `omarchy theme ...`.
- Plymouth theme: `default/plymouth/archer/` → `/usr/share/plymouth/themes/archer/` (installed by `install/login/plymouth.sh`).
- Limine branding: `default/limine/limine.conf` (`interface_branding: Archer`, forest-green palette).

To add a theme: copy an existing theme dir, edit `colors.toml` / `background.jpg`, then `theme-set <new-name>`.
