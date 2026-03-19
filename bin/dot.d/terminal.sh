#!/usr/bin/env bash
# ============================================================================
# @file        bin/dot.d/terminal.sh
# @description Terminal management — info, update, reinstall for all
#              supported terminals (Ghostty, WezTerm, Kitty, Alacritty, iTerm).
# @version     1.0.0
# ============================================================================

cmd_terminal() {
    local action="${1:-}"
    local terminal="${2:-}"
    shift 2 2> /dev/null || true

    # ── Auto-detect current terminal if not specified ──────────────────
    if [[ -z "$terminal" && -z "$action" ]] || [[ "$action" == "info" && -z "$terminal" ]]; then
        terminal="${TERM_PROGRAM:-}"
        case "$terminal" in
            ghostty | Ghostty) terminal="ghostty" ;;
            WezTerm) terminal="wezterm" ;;
            iTerm.app) terminal="iterm" ;;
            *)
                [[ "${TERM:-}" == "xterm-kitty" ]] && terminal="kitty"
                [[ -n "${ALACRITTY_SOCKET:-}" ]] && terminal="alacritty"
                [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]] && terminal="ghostty"
                ;;
        esac
    fi

    case "$action" in
        info)
            if [[ -n "$terminal" ]]; then
                zsh -ic "${terminal}-info" 2> /dev/null || _err "Unknown terminal: ${terminal}"
            else
                _banner
                _section "${I_TERMINAL}  Terminals"
                printf '  %b%-14s %-10s %s%b\n' "${S_BOLD}${C_TEXT}" "TERMINAL" "STATUS" "CONFIG" "$S_RESET"
                _separator

                local name config_dir installed active config_status
                for name in ghostty wezterm kitty alacritty iterm; do
                    config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/${name}"
                    installed="○"
                    active=""
                    config_status="❌"

                    case "$name" in
                        ghostty)
                            _has ghostty && installed="✅"
                            [[ -n "${GHOSTTY_RESOURCES_DIR:-}" ]] && active=" ◀ active"
                            ;;
                        wezterm)
                            _has wezterm && installed="✅"
                            [[ "${TERM_PROGRAM:-}" == "WezTerm" ]] && active=" ◀ active"
                            ;;
                        kitty)
                            _has kitty && installed="✅"
                            [[ "${TERM:-}" == "xterm-kitty" ]] && active=" ◀ active"
                            ;;
                        alacritty)
                            _has alacritty && installed="✅"
                            [[ -n "${ALACRITTY_SOCKET:-}" ]] && active=" ◀ active"
                            ;;
                        iterm)
                            [[ -d "/Applications/iTerm.app" ]] && installed="✅"
                            [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]] && active=" ◀ active"
                            ;;
                    esac

                    [[ -d "${config_dir}/.git" ]] && config_status="✅ cloned"
                    [[ -d "${config_dir}" && ! -d "${config_dir}/.git" ]] && config_status="📁 local"

                    printf '  %b%-14s%b %s  %-12s %b%s%b\n' "$C_TEXT" "$name" "$S_RESET" "$installed" "$config_status" "$C_OVERLAY" "$active" "$S_RESET"
                done
                printf '\n'
            fi
            ;;

        update)
            if [[ -n "$terminal" ]]; then
                zsh -ic "${terminal}-update" 2> /dev/null || _err "Unknown: ${terminal}"
            else
                _banner
                _section "${I_TERMINAL}  Updating All Terminals"
                for t in ghostty wezterm kitty alacritty; do
                    local dir="${XDG_CONFIG_HOME:-${HOME}/.config}/${t}"
                    if [[ -d "${dir}/.git" ]]; then
                        printf '  %b%b%b  %s%b\n' "$C_BLUE" "$I_LOADING" "$S_RESET" "$t" "$S_RESET"
                        git -C "$dir" pull --rebase --quiet 2> /dev/null && _ok "$t updated" || _warn "$t failed"
                    fi
                done
                printf '\n'
            fi
            ;;

        reinstall)
            [[ -z "$terminal" ]] && {
                _err "Usage: dot terminal reinstall <name>"
                return 1
            }
            zsh -ic "${terminal}-reinstall" 2> /dev/null || _err "Unknown: ${terminal}"
            ;;

        edit)
            [[ -z "$terminal" ]] && terminal="${TERM_PROGRAM:-ghostty}"
            case "$terminal" in
                ghostty | Ghostty) terminal="ghostty" ;;
                WezTerm) terminal="wezterm" ;;
                iTerm.app) terminal="iterm" ;;
            esac
            zsh -ic "${terminal}-edit" 2> /dev/null || _err "Unknown: ${terminal}"
            ;;

        list | ls)
            _banner
            _section "${I_TERMINAL}  Supported Terminals"
            printf '  %bghostty%b       %bhttps://ghostty.org%b\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            printf '  %bwezterm%b       %bhttps://wezfurlong.org/wezterm%b\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            printf '  %bkitty%b         %bhttps://sw.kovidgoyal.net/kitty%b\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            printf '  %balacritty%b     %bhttps://alacritty.org%b\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            printf '  %biterm%b         %bhttps://iterm2.com%b\n\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            ;;

        *)
            printf '\n  %b%b%b  Terminal Management%b\n\n' "$S_BOLD" "$C_TEXT" "$I_TERMINAL" "$S_RESET"
            printf '    %binfo%b [name]       Terminal info (auto-detects current)\n' "$C_TEAL" "$S_RESET"
            printf '    %bupdate%b [name]     Update config (all if no name)\n' "$C_TEAL" "$S_RESET"
            printf '    %breinstall%b <name>  Remove and reclone config\n' "$C_TEAL" "$S_RESET"
            printf '    %bedit%b [name]       Edit terminal config\n' "$C_TEAL" "$S_RESET"
            printf '    %blist%b              Show supported terminals\n\n' "$C_TEAL" "$S_RESET"
            printf '  %bExamples:%b\n' "$S_BOLD" "$S_RESET"
            printf '    %bdot terminal%b              Info for current terminal\n' "$C_OVERLAY" "$S_RESET"
            printf '    %bdot terminal info ghostty%b  Ghostty info\n' "$C_OVERLAY" "$S_RESET"
            printf '    %bdot terminal update%b        Update all terminal configs\n' "$C_OVERLAY" "$S_RESET"
            printf '    %bdot terminal edit%b          Edit current terminal config\n\n' "$C_OVERLAY" "$S_RESET"
            ;;
    esac
}
