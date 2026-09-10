# Contributing (Archer)

- Repo: `git@github.com:abr60/Archer.git` (`~/Archer`, branch `main`, remote `origin`). Public.
- Helpers: `install/lib/helpers.sh` — `section/msg/ok/warn/err/die`, `ensure_installed`, `is_installed` (`pacman -Q`), `run_step <script> <label> [critical]`, `ARCHER_DIR` (`~/.local/share/Archer`), `INSTALL_DIR`, colors, `print_logo`, `gum` prompts, `enable_system_service`/`enable_user_service`.
- Install flow: `setup.sh` → packages → shell (zsh) → dotfiles (stow) → system/hardware/services → login (sddm, limine, plymouth, agents).
- Update flow: `update.sh` (remote-first: `git fetch` + `git reset --hard origin/main` style, then re-apply `install/` scripts, boot sync, config symlinks, reload UI). Logs to `~/.local/state/Archer/update-report.txt`.
- Adding a skill: create `default/agents/skills/<name>/SKILL.md` (YAML frontmatter `name:` + `description:`), add guides, then `install/login/agents.sh` links it to `~/.agents/skills` etc.
- Adding a menu entry: edit `bin/menu` (`show_*_menu()`), wire into parent menu + `go_to_menu()`. Keep `menu()` width 295px, listview 15 lines.
- Adding a bin command: create `bin/<name>` with header `# archer:summary=` / `omarchy:summary=` etc., `chmod +x`, dispatcher `bin/omarchy` auto-discovers it.
- Before commit: `bash -n bin/* install/**/*.sh setup.sh update.sh` — all must pass.
