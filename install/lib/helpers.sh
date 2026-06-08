#!/usr/bin/env bash
# =============================================================================
# lib/helpers.sh — Shared helper functions for Archer install scripts
# Source at the top of every install script:
#   source "$(dirname "${BASH_SOURCE[0]}")/../lib/helpers.sh"
# =============================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

msg()     { echo -e "${BLUE}==>${NC} $1"; }
ok()      { echo -e "${GREEN} ✓${NC} $1"; }
warn()    { echo -e "${YELLOW} !${NC} $1"; }
err()     { echo -e "${RED} ✗${NC} $1"; }
die()     { echo -e "${RED}ERR${NC} $1"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}--- $1 ---${NC}"; }

has_gum() { command -v gum &>/dev/null; }

spinner() {
    local title="$1"; shift
    if has_gum; then
        gum spin --spinner dot --title "$title" --show-error -- "$@"
    else
        echo -e "${CYAN}⟳${NC} $title"
        "$@"
    fi
}

ask_yes_no() {
    local prompt="$1"
    if has_gum; then
        gum confirm "$prompt" && return 0 || return 1
    else
        while true; do
            read -rp "$prompt [y/n]: " yn
            case $yn in
                [Yy]*) return 0 ;;
                [Nn]*) return 1 ;;
                *) echo "Please answer y or n." ;;
            esac
        done
    fi
}

gum_input() {
    local placeholder="$1"
    if has_gum; then
        gum input --placeholder "$placeholder"
    else
        read -rp "$placeholder: " val
        echo "$val"
    fi
}

is_installed() { pacman -Q "$1" &>/dev/null; }

ensure_installed() {
    local pkg="$1"
    if ! is_installed "$pkg"; then
        msg "Installing $pkg..."
        sudo pacman -S --needed --noconfirm "$pkg"
        ok "$pkg installed"
    fi
}

remove_path() {
    local target="$1"
    if [[ -L "$target" ]]; then
        rm -f "$target"
    elif [[ -e "$target" ]]; then
        rm -rf "$target"
    fi
}

ensure_dir() { mkdir -p "$1"; }

is_laptop() {
    ls /sys/class/power_supply/BAT* &>/dev/null || \
    [[ -d /sys/class/power_supply/battery ]]
}

detect_hardware_type() { is_laptop && echo "laptop" || echo "desktop"; }
has_battery() { is_laptop; }

ARCHER_DIR="${ARCHER_DIR:-$HOME/.local/share/Archer}"
ARCHER_BIN="$ARCHER_DIR/bin"
archer_bin_present() { [[ -x "$ARCHER_BIN/$1" ]]; }

unit_exists_system() { systemctl cat "$1" &>/dev/null; }
unit_exists_user()   { systemctl --user cat "$1" &>/dev/null; }
is_enabled_system()  { systemctl is-enabled "$1" &>/dev/null; }
is_enabled_user()    { systemctl --user is-enabled "$1" &>/dev/null; }

enable_system_service() {
    local svc="$1"
    if ! unit_exists_system "$svc"; then warn "$svc not found — skipping"; return; fi
    if is_enabled_system "$svc"; then ok "$svc already enabled — skipping"; return; fi
    sudo systemctl enable "$svc" && ok "Enabled $svc" || warn "Failed to enable $svc"
}

enable_user_service() {
    local svc="$1"
    if ! unit_exists_user "$svc"; then warn "$svc (user) not found — skipping"; return; fi
    if is_enabled_user "$svc"; then ok "$svc (user) already enabled — skipping"; return; fi
    systemctl --user enable "$svc" && ok "Enabled $svc (user)" || warn "Failed to enable $svc (user)"
}
