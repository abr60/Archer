# Rofi Menu (Archer)

Archer's menu is `bin/menu` (Rofi dmenu). Dispatcher is `bin/omarchy` (routes `omarchy <group> <action>` → `bin/omarchy-*` / `bin/archer-*`).

```
bin/menu
├── show_main_menu        → Apps / Learn / Trigger / Style / Setup / Install / Remove / Update / About / System
├── show_setup_menu       → Audio / Wifi / Bluetooth / Power / Monitors / Keybindings / Input / Defaults / DNS / Security / Config
│   └── show_setup_config_menu → Hyprland / Hypridle / Hyprlock / Hyprsunset / Swayosd / Waybar / Rofi / XCompose
│   └── show_setup_default_menu → Browser / Terminal / Editor
├── show_install_menu     → Package / AUR / Web App / TUI / Service / Style / Development / Editor / Terminal / Browser / AI / Gaming / Windows
│   └── show_install_ai_menu → Dictation / LM Studio / Ollama / Crush + AI Web Apps (ChatGPT, Claude, Gemini, Grok, DeepSeek, Mistral, NotebookLM)
├── show_trigger_menu / show_style_menu / show_update_menu / show_system_menu / ...
└── go_to_menu           (direct jump: `menu Install`, `menu Setup`, etc.)
```

- Edit: `~/Archer/bin/menu` (922 lines). Add submenus as `show_*_menu()` functions, wire in `show_install_menu` / `go_to_menu` / `show_main_menu`.
- Helpers: `menu()`, `present_terminal()`, `install()`, `open_in_editor()`, `hypr_config_file()`.
- User extensions: `~/.config/archer/extensions/menu.sh` (sourced at end of `bin/menu`).
- Install helpers: `bin/webapp-install`, `bin/webapp-remove`, `bin/tui-install`, `bin/pkg-add`, `bin/install-*`, `bin/archer-voxtype-*`.
- Webapps: `applications/Webapps/*.desktop` + `applications/icons/*.png` → `~/.local/share/applications/` (via `install/config/applications.sh` + `bin/refresh-applications`).
