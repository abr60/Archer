#!/usr/bin/env bash
# =============================================================================
# lib/backup.sh — Backup and rollback system for Archer install scripts
# =============================================================================

BACKUP_ROOT="$HOME/.local/share/archer-backups"
_BACKUP_SESSION_FILE="$HOME/.local/share/Archer/.archer-backup-session"

init_backup_session() {
    local session="backup_$(date +%Y%m%d_%H%M%S)"
    BACKUP_DIR="$BACKUP_ROOT/$session"
    RESTORE_FILE="$BACKUP_DIR/RESTORE.txt"

    mkdir -p "$BACKUP_DIR"

    cat > "$_BACKUP_SESSION_FILE" << SESS
BACKUP_DIR="$BACKUP_DIR"
RESTORE_FILE="$RESTORE_FILE"
SESS

    {
        echo "Archer Backup"
        echo "============="
        echo "Created : $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Session : $session"
        echo "Machine : $(cat /etc/hostname)"
        echo ""
        echo "Files backed up:"
    } > "$RESTORE_FILE"

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -f "$script_dir/rollback.sh" ]]; then
        cp "$script_dir/rollback.sh" "$BACKUP_DIR/rollback.sh"
        chmod +x "$BACKUP_DIR/rollback.sh"
    fi

    ok "Backup session started: $session"
    ok "Backup location: $BACKUP_DIR"
}

load_backup_session() {
    if [[ -z "${BACKUP_DIR:-}" ]]; then
        if [[ -f "$_BACKUP_SESSION_FILE" ]]; then
            source "$_BACKUP_SESSION_FILE"
        else
            warn "No backup session found — backups will be skipped"
            BACKUP_DIR=""
            RESTORE_FILE=""
        fi
    fi
}

backup_file() {
    local source_path="$1"
    load_backup_session
    [[ -z "${BACKUP_DIR:-}" ]] && return 0
    [[ ! -e "$source_path" ]] && return 0

    local rel_path="${source_path#/}"
    local backup_path="$BACKUP_DIR/$rel_path"
    local backup_parent
    backup_parent="$(dirname "$backup_path")"

    mkdir -p "$backup_parent" || { warn "Failed to create backup dir: $backup_parent"; return 1; }

    if [[ "$source_path" == "$HOME"* ]]; then
        cp -rP "$source_path" "$backup_path" || { warn "Failed to backup: $source_path"; return 1; }
    else
        sudo cp -rP "$source_path" "$backup_path" || { warn "Failed to backup: $source_path"; return 1; }
    fi

    local rm_cmd cp_cmd
    if [[ -d "$source_path" ]]; then
        rm_cmd="rm -rf \"$source_path\""
        cp_cmd="cp -rP \"$backup_path\" \"$(dirname "$source_path")/\""
    else
        rm_cmd="rm -f \"$source_path\""
        cp_cmd="cp -P \"$backup_path\" \"$source_path\""
    fi

    if [[ "$source_path" != "$HOME"* ]]; then
        rm_cmd="sudo $rm_cmd"
        cp_cmd="sudo $cp_cmd"
    fi

    {
        echo ""
        echo "- $source_path"
        echo "  Restore: $rm_cmd && $cp_cmd"
    } >> "$RESTORE_FILE"

    ok "Backed up: $source_path"
}

cleanup_backup_session() {
    rm -f "$_BACKUP_SESSION_FILE"
    ok "Backup session closed"
    ok "To restore: bash $BACKUP_DIR/rollback.sh"
}
