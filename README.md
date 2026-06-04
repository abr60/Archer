# Archer

[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org/)

A personal Hyprland dotfiles setup, built around a ThinkPad T14 Gen 2 (i5) running Arch Linux. Not a framework, not a rice template — just my own configuration, structured the way I want it.

---

## Structure

```
~/Archer/
├── applications/       # Desktop entries and binary setup
├── bin/                # Custom scripts and executables
├── config/             # Personal config files — stowed into ~/.config
├── default/            # Archer system defaults (do not edit)
├── fonts/              # Font installation
├── install/            # All install scripts + package lists
├── system/
│   ├── greetd/         # Login manager config
│   ├── thinkfan/       # Fan control for ThinkPad
│   └── easyeffects/    # DSP presets for T14 speakers
├── docs/
│   └── Instruction/    # Notes and references
├── README.md
└── setup.sh            # Entry point
```

---

## How It Works

Archer uses a layered approach:

- `default/hypr/` holds system-level Hyprland defaults — sourced first, not meant to be touched
- `config/hypr/` holds personal overrides — sourced after, these win
- Stow symlinks everything from `config/` into `~/.config/`
- The repo lives at `~/Archer/` and is symlinked to `~/.local/share/Archer/` — one source of truth, everything else points back to it

This means you edit files in your repo, push to GitHub, and the running system reflects it immediately through the symlinks. No copying, no syncing.

---

## Installation

```bash
git clone https://github.com/drunk-particles/Archer.git ~/Archer
bash ~/Archer/setup.sh
```

During setup you'll be asked to choose an install mode:

- **minimal** — core packages only, installs fast
- **complete** — everything including optional and heavy apps

> ⚠️ This is configured for my machine. Speaker DSP presets, fan curves, and hardware-specific settings are tuned for a ThinkPad T14 Gen 2 (i5). Use at your own discretion on other hardware.

---

## Stack

| Layer          | Tool              |
| -------------- | ----------------- |
| Compositor     | Hyprland          |
| Shell          | Zsh + Oh My Zsh   |
| Terminal       | Ghostty           |
| Bar / Shell UI | Quickshell        |
| Notifications  | swaync            |
| Launcher       | Rofi              |
| Login Manager  | greetd + tuigreet |
| Audio DSP      | EasyEffects       |
| Fan Control    | Thinkfan          |
| Theming        | Matugen           |
| File Manager   | Nautilus + Yazi   |
| Editor         | Neovim + VS Code  |
| Music          | mpd + rmpc        |

---

## Notes

- Arch Linux only
- Wayland only — no X11 fallback
- Some scripts are ThinkPad-specific and will gracefully skip on other hardware
- Waydroid support is present but commented out — not actively maintained

---

*by [drunk-particles](https://github.com/drunk-particles)*
