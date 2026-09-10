---
name: archer
description: >
  REQUIRED for Archer Linux desktop, window manager, or system config.
  Use when editing ~/.config/hypr/, ~/.config/waybar/, ~/.config/rofi/,
  or any file in ~/.config/ on an Archer system, or when working inside
  the Archer repo at ~/Archer / ~/.local/share/Archer.
  Triggers: Hyprland, window rules, animations, keybindings, monitors,
  gaps, borders, blur, opacity, Waybar, Rofi menu, themes, background,
  night light, idle, lock screen, screenshots, reminders, layer rules,
  workspace settings, display config, Limine, Plymouth, LUKS, and
  user-facing archer/omarchy commands.
---

# Archer Skill

Manage **Archer** — a beautiful, modern, opinionated Arch Linux distribution with Hyprland, forked from Omarchy.

Archer repo lives at `~/Archer` (`/home/$USER/Archer`) and is symlinked to `~/.local/share/Archer` (`$ARCHER_DIR`) during setup. That symlink is the **source of truth** for all scripts (`$ARCHER_DIR/default/`, `$ARCHER_DIR/config/`, `$ARCHER_DIR/bin/`, `$ARCHER_DIR/install/`).

> `~/.agents/skills/archer` is a **symlink** to `~/.local/share/Archer/default/agents/skills/archer` (also linked into `~/.claude/skills/`, `~/.codex/skills/`, `~/.pi/agent/skills/`).

## When This Skill MUST Be Used

**Always invoke this skill for requests involving:**

- Editing ANY file in `~/.config/hypr/` (hyprland.lua, bindings.lua, monitors.lua, input.lua, looknfeel.lua, autostart.lua, hypridle/hyprlock/hyprsunset configs)
- Editing `~/.config/waybar/` (bar layout, modules)
- Editing `~/.config/rofi/` or the Archer menu (`~/Archer/bin/menu`)
- Editing ANY file in `~/.config/` on an Archer system
- Window behavior, animations, opacity, blur, gaps, borders, workspaces
- Themes, backgrounds, fonts, appearance (`bin/theme-*`, `bin/theme-bg-*`, `bin/font-*`)
- Boot stack: Limine (`/boot/limine.conf`), Plymouth, LUKS (`/etc/kernel/cmdline`, `/etc/mkinitcpio.conf.d/`)
- User-facing `archer`/`omarchy` commands (`archer theme ...`, `archer refresh ...`, etc.)
- Working inside the Archer repo itself (`~/Archer/setup.sh`, `update.sh`, `install/`, `bin/`, `default/`, `config/`, `applications/`)

**If you're about to edit a config file in `~/.config/` or touch `~/Archer/`, STOP and use this skill first.**

## Topic Guides

Deeper instructions live next to this file. Read the matching guide before starting:

- [`hyprland.md`](hyprland.md) — keybindings, monitors, window rules, Hyprland Lua config
- [`waybar.md`](waybar.md) — Waybar layout, modules, styling
- [`theming.md`](theming.md) — themes, backgrounds, fonts
- [`menu.md`](menu.md) — Rofi menu (`bin/menu`), command dispatcher (`bin/omarchy` / `bin/archer-*/`)
- [`boot.md`](boot.md) — Limine + LUKS + Plymouth + mkinitcpio
- [`contributing.md`](contributing.md) — hacking on the Archer repo itself

## Critical Safety Rules

**For end-user customization, NEVER modify `/usr/share/omarchy/` or the installed `~/.local/share/Archer` copy directly** — edit the repo at `~/Archer/` and re-run `install/` scripts or `update.sh`. Reading is always safe.

```
~/Archer/                        # EDIT HERE (git repo, then update.sh)
├── bin/                         # Commands (archer-*, omarchy-*, menu, webapp-*, theme-*)
├── config/                      # Dotfiles deployed via stow (hypr, waybar, rofi, etc.)
├── default/                     # System defaults (limine/limine.conf, agents/skills/*)
├── applications/                # Desktop entries (Webapps/*.desktop, icons/*.png)
├── install/                     # Setup scripts (lib/helpers.sh, login/, system/, hardware/, packaging/)
├── themes/                      # Themes
├── setup.sh                     # First-time installer
└── update.sh                    # Remote-first updater (git fetch + re-apply)
```

**Safe edit locations:**
- `~/Archer/config/<app>/` — dotfiles (stowed to `~/.config/`)
- `~/Archer/default/agents/skills/archer/` — this skill itself
- `~/Archer/bin/menu` — Rofi menu structure
- `~/.config/` — live user config (overwritten by `update.sh` re-apply, so prefer editing the repo)

## Privilege Escalation

Interactive terminal work → `sudo`. Non-interactive / agent-launched → `pkexec`. Don't wrap commands that already handle privilege themselves (e.g. `omarchy-*` wrappers).

## System Architecture

| Component | Purpose | Config Location |
|-----------|---------|-----------------|
| **Arch Linux** | Base OS | `/etc/`, `~/.config/` |
| **Hyprland** | Wayland compositor | `~/.config/hypr/*.lua` + `hypr*.conf` |
| **Waybar** | Status bar | `~/.config/waybar/` |
| **Rofi** | App launcher + Archer menu | `~/.config/rofi/`, `bin/menu` |
| **SDDM** | Display manager | `/etc/sddm.conf.d/` |
| **Limine** | Bootloader (with LUKS) | `/boot/limine.conf`, `/etc/kernel/cmdline`, `/etc/limine-entry-tool.d/` |
| **Plymouth** | Boot splash | `/usr/share/plymouth/themes/archer/`, `/etc/plymouth/plymouthd.conf` |
| **Alacritty/Foot/Ghostty/Kitty** | Terminals | `~/.config/<terminal>/` |

## Command Discovery

Archer ships an `omarchy` dispatcher (also available as `archer` on some installs) that routes `omarchy <group> <action>` to `omarchy-*` / `archer-*` binaries:

```bash
omarchy commands              # list every documented command
omarchy theme --help
omarchy agent --help
omarchy-agent --help
bin/menu --help 2>/dev/null || cat ~/Archer/bin/menu | head -20
```

Prefer `omarchy <group> <action>` — it's self-documenting and stable. The underlying `bin/*` binaries remain readable for source.

## Agents

Archer links `default/agents/skills/archer` into every supported agent skills dir
(`~/.agents/skills`, `~/.claude/skills`, `~/.codex/skills`, `~/.pi/agent/skills`)
via `install/login/agents.sh` (run during `setup.sh` and `update.sh`).
`diagnose-crash` is also linked for crash triage. `bin/restart-opencode` (SIGUSR2)
reloads opencode after skill changes.
