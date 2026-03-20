#!/usr/bin/env bash
# ============================================================================
# @file        bin/dot.d/macos.sh
# @description macOS Defaults Management — apply, backup, restore system
#              preferences via modular defaults.d/ scripts.
#              Uses SSOT colors/icons from _core.sh.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @version     1.0.0
#
# @depends     bin/dot.d/_core.sh
# ============================================================================

# ── Constants ────────────────────────────────────────────────────────────────
DARWIN_DEFAULTS_DIR="${DOTFILES_DIR}/platform/darwin-defaults"
DEFAULTS_D_DIR="${DARWIN_DEFAULTS_DIR}/defaults.d"
BACKUP_DIR="${HOME}/.local/share/dotfiles/macos-defaults-backup"
LOG_FILE="${HOME}/.local/share/dotfiles/macos-defaults.log"

# ── State ────────────────────────────────────────────────────────────────────
_MACOS_DRY_RUN=false
_MACOS_FORCE=false
_MACOS_CHANGES=0
_MACOS_ERRORS=0
_MACOS_SKIPPED=0

# ============================================================================
# Helpers — defaults write/delete wrappers
# ============================================================================

# @description  Wrapper around `defaults write` that respects --dry-run
#               and uses SSOT formatting from _core.sh.
# @param  $1    string  Domain (e.g., com.apple.dock)
# @param  $2    string  Key
# @param  $3    string  Type (bool, int, float, string, -array)
# @param  $@    mixed   Value(s)
# @return       void
dw() {
    local domain="$1" key="$2" type="$3"
    shift 3
    local value="$*"

    if $_MACOS_DRY_RUN; then
        printf '   %b→ [DRY-RUN]%b defaults write %s %s -%s %s\n' \
            "$C_OVERLAY" "$S_RESET" "$domain" "$key" "$type" "$value"
        ((_MACOS_SKIPPED++))
    else
        if defaults write "$domain" "$key" "-${type}" $value 2> /dev/null; then
            printf '   %b→%b %b%s%b %s → %b%s%b\n' \
                "$C_TEAL" "$S_RESET" "$C_SUBTEXT" "$domain" "$S_RESET" "$key" "$C_GREEN" "$value" "$S_RESET"
            ((_MACOS_CHANGES++))
        else
            _warn "Failed: defaults write ${domain} ${key} -${type} ${value}"
            ((_MACOS_ERRORS++))
        fi
    fi
}

# @description  Delete a defaults key (silent if missing)
# @param  $1    string  Domain
# @param  $2    string  Key
# @return       void
dd() {
    local domain="$1" key="$2"

    if $_MACOS_DRY_RUN; then
        printf '   %b→ [DRY-RUN]%b defaults delete %s %s\n' \
            "$C_OVERLAY" "$S_RESET" "$domain" "$key"
    else
        defaults delete "$domain" "$key" 2> /dev/null || true
    fi
}

# ============================================================================
# Module Runner
# ============================================================================

# @description  Source a single defaults.d/ module
# @param  $1    string  Path to module file
# @return       void
_macos_run_module() {
    local module_file="$1"
    local module_name display_name

    module_name="$(basename "$module_file" .sh)"
    display_name="${module_name#[0-9][0-9]-}"

    _section "${I_SETTINGS} ${display_name}"

    if [[ -f "$module_file" && -r "$module_file" ]]; then
        # shellcheck source=/dev/null
        source "$module_file"
        _ok "Module ${display_name} applied"
    else
        _err "Module not found or unreadable: ${module_file}"
        ((_MACOS_ERRORS++))
    fi
}

# @description  Resolve a module name to its file path
# @param  $1    string  Module name (e.g., "dock")
# @return       string  Full path or empty
_macos_resolve_module() {
    local target="$1"
    for f in "${DEFAULTS_D_DIR}"/*.sh; do
        local name display
        name="$(basename "$f" .sh)"
        display="${name#[0-9][0-9]-}"
        if [[ "$display" == "$target" ]]; then
            echo "$f"
            return 0
        fi
    done
    return 1
}

# ============================================================================
# Backup / Restore
# ============================================================================

# @description  Backup current macOS preferences to timestamped plist files
# @return       void
_macos_backup() {
    local backup_path="${BACKUP_DIR}/$(date '+%Y%m%d_%H%M%S')"
    mkdir -p "$backup_path"

    _section "${I_SHIELD} Backup Current Preferences"

    local domains=(
        "NSGlobalDomain"
        "com.apple.dock"
        "com.apple.finder"
        "com.apple.Safari"
        "com.apple.screencapture"
        "com.apple.screensaver"
        "com.apple.menuextra.clock"
        "com.apple.ActivityMonitor"
        "com.apple.TextEdit"
        "com.apple.DiskUtility"
        "com.apple.mail"
        "com.apple.iCal"
        "com.apple.desktopservices"
        "com.apple.frameworks.diskimages"
        "com.apple.LaunchServices"
        "com.apple.NetworkBrowser"
        "com.apple.SoftwareUpdate"
        "com.apple.universalaccess"
        "com.apple.AppleMultitouchTrackpad"
        "com.apple.terminal"
        "com.apple.assistant.support"
        "com.apple.AdLib"
        "com.apple.print.PrintingPrefs"
    )

    local backed=0
    for domain in "${domains[@]}"; do
        if defaults read "$domain" &> /dev/null; then
            defaults export "$domain" "${backup_path}/${domain}.plist" 2> /dev/null
            printf '   %b→%b %s\n' "$C_TEAL" "$S_RESET" "$domain"
            ((backed++))
        fi
    done

    ln -sfn "$backup_path" "${BACKUP_DIR}/latest"
    _ok "Backed up ${backed} domains → ${backup_path}"
}

# @description  Restore preferences from a backup
# @param  $1    string  (optional) Backup path (default: latest)
# @return       void
_macos_restore() {
    local restore_path="${1:-${BACKUP_DIR}/latest}"

    if [[ ! -d "$restore_path" ]]; then
        _err "Backup not found: ${restore_path}"
        return 1
    fi

    _section "${I_LOADING} Restoring Preferences"

    local restored=0
    for plist in "${restore_path}"/*.plist; do
        [[ -f "$plist" ]] || continue
        local domain
        domain="$(basename "$plist" .plist)"
        if defaults import "$domain" "$plist" 2> /dev/null; then
            printf '   %b→%b %s\n' "$C_TEAL" "$S_RESET" "$domain"
            ((restored++))
        else
            _warn "Failed to restore: ${domain}"
        fi
    done

    _ok "Restored ${restored} domains from ${restore_path}"
    _warn "Restart affected apps or log out to apply"
}

# ============================================================================
# Restart Affected Apps
# ============================================================================

# @description  Kill and restart macOS system apps affected by defaults changes
# @return       void
_macos_restart_apps() {
    if $_MACOS_DRY_RUN; then
        _info "[DRY-RUN] Would restart affected applications"
        return
    fi

    _section "${I_ROCKET} Restarting Affected Applications"

    local apps=("Dock" "Finder" "SystemUIServer" "cfprefsd")
    for app in "${apps[@]}"; do
        if killall "$app" 2> /dev/null; then
            printf '   %b→%b Restarted %b%s%b\n' "$C_TEAL" "$S_RESET" "$C_TEXT" "$app" "$S_RESET"
        fi
    done

    _ok "Applications restarted"
    _warn "Some changes require a logout/restart to take effect"
}

# ============================================================================
# List Modules
# ============================================================================

# @description  List all available defaults.d/ modules
# @return       void
_macos_list() {
    _section "${I_FOLDER} Available Modules"

    if [[ ! -d "$DEFAULTS_D_DIR" ]]; then
        _err "defaults.d/ directory not found: ${DEFAULTS_D_DIR}"
        return 1
    fi

    local count=0
    for f in "${DEFAULTS_D_DIR}"/*.sh; do
        [[ -f "$f" ]] || continue
        local name display
        name="$(basename "$f" .sh)"
        display="${name#[0-9][0-9]-}"
        printf '  %b%-16s%b %b%s%b\n' "$C_TEAL" "$display" "$S_RESET" "$C_OVERLAY" "$f" "$S_RESET"
        ((count++))
    done

    echo ""
    _info "${count} modules available"
}

# ============================================================================
# Apply — Main Orchestrator
# ============================================================================

# @description  Apply macOS defaults from modular defaults.d/ files
# @param  $@    Options: --dry-run, --module <name>, --force
# @return       void
_macos_apply() {
    local target_module=""

    # ── Parse arguments ──────────────────────────────────────────────────
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) _MACOS_DRY_RUN=true ;;
            --force) _MACOS_FORCE=true ;;
            --module)
                target_module="${2:?Missing module name}"
                shift
                ;;
            *)
                _err "Unknown option: $1"
                return 1
                ;;
        esac
        shift
    done

    # ── Header ───────────────────────────────────────────────────────────
    printf '\n  %b%b%b  macOS Defaults Manager%b\n' \
        "$C_MAUVE" "$S_BOLD" "$I_MACOS" "$S_RESET"
    printf '  %bmacOS %s · %s · %s%b\n' \
        "$C_OVERLAY" "$(sw_vers -productVersion)" "$(whoami)" "$(hostname -s)" "$S_RESET"
    _separator

    if $_MACOS_DRY_RUN; then
        echo ""
        _warn "DRY-RUN mode — no changes will be applied"
    fi

    # ── Confirmation ─────────────────────────────────────────────────────
    if ! $_MACOS_FORCE && ! $_MACOS_DRY_RUN; then
        echo ""
        printf '  %bThis will modify macOS system preferences.%b\n' "$C_YELLOW" "$S_RESET"
        printf '  Continue? [y/N] '
        read -r confirm
        if [[ "$confirm" != [yY] ]]; then
            _info "Cancelled."
            return 0
        fi

        # Auto-backup before applying
        _macos_backup
    fi

    # ── Close System Settings to prevent conflicts ───────────────────────
    if ! $_MACOS_DRY_RUN; then
        osascript -e 'tell application "System Preferences" to quit' 2> /dev/null || true
        osascript -e 'tell application "System Settings" to quit' 2> /dev/null || true
        sleep 1
    fi

    # ── Logging ──────────────────────────────────────────────────────────
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] apply started (dry-run=${_MACOS_DRY_RUN}, module=${target_module:-all})" >> "$LOG_FILE"

    # ── Run modules ──────────────────────────────────────────────────────
    if [[ -n "$target_module" ]]; then
        local target_file
        target_file="$(_macos_resolve_module "$target_module")" || {
            _err "Module not found: ${target_module}"
            echo ""
            _macos_list
            return 1
        }
        _macos_run_module "$target_file"
    else
        for f in "${DEFAULTS_D_DIR}"/*.sh; do
            [[ -f "$f" ]] && _macos_run_module "$f"
        done
    fi

    # ── Restart apps ─────────────────────────────────────────────────────
    if [[ $_MACOS_CHANGES -gt 0 ]]; then
        echo ""
        _macos_restart_apps
    fi

    # ── Summary ──────────────────────────────────────────────────────────
    echo ""
    _separator
    printf '  %b%b  Summary%b\n' "$S_BOLD" "$I_INFO" "$S_RESET"
    _separator
    _kv "Applied:" "${C_GREEN}${_MACOS_CHANGES} changes${S_RESET}"
    _kv "Skipped:" "${C_YELLOW}${_MACOS_SKIPPED}${S_RESET}"
    _kv "Errors:" "${C_RED}${_MACOS_ERRORS}${S_RESET}"
    _kv "Log:" "${C_OVERLAY}${LOG_FILE}${S_RESET}"
    if [[ -L "${BACKUP_DIR}/latest" ]]; then
        _kv "Backup:" "${C_OVERLAY}$(readlink "${BACKUP_DIR}/latest")${S_RESET}"
    fi
    _separator

    # ── Log completion ───────────────────────────────────────────────────
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] apply completed: ${_MACOS_CHANGES} changes, ${_MACOS_ERRORS} errors" >> "$LOG_FILE"
}

# ============================================================================
# Command Router — called by bin/dot dispatcher
# ============================================================================

# @description  Main entry point for `dot macos <subcommand>`
# @param  $@    Subcommand and options
# @return       void
cmd_macos() {
    # Guard: macOS only
    if [[ "$(uname -s)" != "Darwin" ]]; then
        _err "dot macos is only available on macOS"
        return 1
    fi

    local subcmd="${1:-help}"
    shift 2> /dev/null || true

    case "$subcmd" in
        apply | a) _macos_apply "$@" ;;
        backup | bak) _macos_backup ;;
        restore | res) _macos_restore "$@" ;;
        list | ls) _macos_list ;;
        help | h | --help | -h) _macos_help ;;
        *)
            _err "Unknown subcommand: ${subcmd}"
            _macos_help
            return 1
            ;;
    esac
}

# ============================================================================
# Help
# ============================================================================

_macos_help() {
    _banner
    printf '\n  %b%b  macOS Defaults Manager%b\n\n' "$S_BOLD" "$I_MACOS" "$S_RESET"

    printf '  %bUSAGE%b\n' "$S_BOLD" "$S_RESET"
    printf '    dot macos <command> [options]\n\n'

    printf '  %bCOMMANDS%b\n' "$S_BOLD" "$S_RESET"
    _kv "apply" "Apply all macOS preferences (auto-backup)"
    _kv "  --dry-run" "Preview changes without applying"
    _kv "  --module X" "Apply single module (dock, finder…)"
    _kv "  --force" "Skip confirmation prompt"
    _kv "backup" "Backup current preferences"
    _kv "restore" "Restore from backup (latest or path)"
    _kv "list" "List available modules"
    _kv "help" "Show this help"

    printf '\n  %bMODULES%b\n' "$S_BOLD" "$S_RESET"
    _kv "general" "Dark mode, locale, save panels, text"
    _kv "dock" "Auto-hide, size, hot corners, spaces"
    _kv "finder" "Column view, hidden files, path bar"
    _kv "safari" "Developer tools, privacy, Do Not Track"
    _kv "input" "Key repeat, trackpad, tap to click"
    _kv "screen" "Screenshots, screen saver password"
    _kv "security" "Firewall, Gatekeeper, auto-updates"
    _kv "energy" "Sleep timers, Power Nap, hibernation"
    _kv "apps" "Activity Monitor, Mail, Calendar…"
    _kv "terminal" "UTF-8, secure keyboard, default shell"
    _kv "accessibility" "Cursor size, zoom, motion"

    printf '\n  %bEXAMPLES%b\n' "$S_BOLD" "$S_RESET"
    printf '    dot macos apply                     %b# Apply all (with backup)%b\n' "$C_OVERLAY" "$S_RESET"
    printf '    dot macos apply --dry-run            %b# Preview all changes%b\n' "$C_OVERLAY" "$S_RESET"
    printf '    dot macos apply --module dock        %b# Dock preferences only%b\n' "$C_OVERLAY" "$S_RESET"
    printf '    dot macos apply --module dock --dry-run\n'
    printf '    dot macos backup                    %b# Backup current state%b\n' "$C_OVERLAY" "$S_RESET"
    printf '    dot macos restore                   %b# Restore latest backup%b\n' "$C_OVERLAY" "$S_RESET"
    printf '    dot macos list                      %b# Available modules%b\n' "$C_OVERLAY" "$S_RESET"
    printf '\n'
}
