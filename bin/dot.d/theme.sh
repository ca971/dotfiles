#!/usr/bin/env bash
cmd_theme() {
    local action="${1:-}"
    shift 2> /dev/null || true
    _ct() { basename "${STARSHIP_CONFIG:-unknown}" .toml | sed 's/starship-//'; }
    _at() {
        local tf="${THEMES_DIR}/starship-${1}.toml"
        [ ! -f "$tf" ] && {
            _err "Not found: $1"
            return 1
        }
        export STARSHIP_CONFIG="$tf" STARSHIP_THEME="$1"
        _ok "Theme ${C_MAUVE}${S_BOLD}${1}${S_RESET} activated"
    }
    case "$action" in
        powerline | minimal | nerd) _at "$action" ;;
        list | ls | l)
            _banner
            _section "${I_PALETTE} Themes"
            printf '  %bCurrent: %b%s%b\n\n' "$C_SUBTEXT" "${C_MAUVE}${S_BOLD}" "$(_ct)" "$S_RESET"
            for t in powerline minimal nerd; do [ "$t" = "$(_ct)" ] && printf '  %b● %-14s%b\n' "${C_SUCCESS}${S_BOLD}" "$t" "$S_RESET" || printf '  %b○ %-14s%b\n' "$C_MUTED" "$t" "$S_RESET"; done
            printf '\n'
            ;;
        preview | p)
            _banner
            _section "${I_PALETTE} Preview"
            local c="$STARSHIP_CONFIG"
            for t in powerline minimal nerd; do
                printf '  %b── %s ──%b\n  ' "${S_BOLD}${C_MAUVE}" "$t" "$S_RESET"
                STARSHIP_CONFIG="${THEMES_DIR}/starship-${t}.toml" starship prompt 2> /dev/null
                printf '\n'
            done
            export STARSHIP_CONFIG="$c"
            ;;
        "") if _has fzf; then
            local ch
            ch=$(printf "powerline\t%s Powerline\nminimal\t%s Minimal\nnerd\t%s Nerd\n" "$I_MACOS" "$I_TERMINAL" "$I_K8S" | fzf --delimiter='\t' --with-nth=2 --header="${I_PALETTE} Current: $(_ct)" --preview="STARSHIP_CONFIG='${THEMES_DIR}/starship-{1}.toml' starship prompt 2>/dev/null" --preview-window='up:3:wrap' --height='40%' --border | cut -f1)
            [ -n "$ch" ] && _at "$ch"
        else
            cmd_theme list
            printf '  Choice: '
            read -r ch
            [ -n "$ch" ] && _at "$ch"
        fi ;;
        *) _err "Unknown: $action" ;;
    esac
}
