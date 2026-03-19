#!/usr/bin/env bash
cmd_alias() {
    local q="${1:-}"
    _banner
    _section "${I_SEARCH}  Aliases"
    local af="${DOTFILES_DIR}/generated/aliases.zsh"
    if [ -n "$q" ]; then
        printf '  %bSearch: %b%s%b\n\n' "$C_SUBTEXT" "$C_TEXT" "$q" "$S_RESET"
        {
            [ -f "$af" ] && grep -i "$q" "$af" | grep "^alias"
            grep -rn "^alias.*$q" "${DOTFILES_DIR}/tools/"*.zsh 2> /dev/null | sed "s|${DOTFILES_DIR}/||"
        } | while IFS= read -r l; do printf '  %b%s%b\n' "$C_SUBTEXT" "$l" "$S_RESET"; done
    elif _has fzf; then
        {
            [ -f "$af" ] && grep "^alias" "$af" | sed 's/^/[ssot] /'
            grep -rn "^alias " "${DOTFILES_DIR}/tools/"*.zsh 2> /dev/null | sed "s|${DOTFILES_DIR}/tools/||" | sed 's/^/[tool] /'
        } | fzf --header="${I_SEARCH} Aliases" --height='70%' --border
    else
        [ -f "$af" ] && grep "^alias" "$af" | head -30
    fi
    printf '\n'
}

cmd_path() {
    _banner
    _section "${I_FOLDER}  PATH Audit"

    local i=0 valid=0 missing=0 on_demand=0 dupes=0
    local seen=""
    local entries
    entries=$(echo "$PATH" | tr ':' '\n')

    while read -r entry; do
        [ -z "$entry" ] && continue
        i=$((i + 1))

        # -- Duplicate check
        local is_dupe=0
        if printf '%s\n' "$seen" | grep -qxF "$entry" 2> /dev/null; then
            is_dupe=1
            dupes=$((dupes + 1))
        fi
        seen="${seen}${entry}
"

        # -- Categorize
        local cat=""
        case "$entry" in
            */homebrew/*) cat="brew" ;;
            */mise/*) cat="mise" ;;
            */cargo/*) cat="cargo" ;;
            */go/*) cat="go" ;;
            */gem/*) cat="ruby" ;;
            */nix*) cat="nix" ;;
            */.local/bin) cat="local" ;;
            */dotfiles/*) cat="dots" ;;
            */carapace/*) cat="tool" ;;
            /usr/* | /bin | /sbin) cat="sys" ;;
            /System/* | */cryptex* | */com.apple*) cat="macos" ;;
            /opt/*) cat="opt" ;;
            */Ghostty*) cat="app" ;;
        esac

        # -- Display
        if [ -d "$entry" ]; then
            valid=$((valid + 1))
            if [ "$is_dupe" -eq 1 ]; then
                printf '  %b%2d%b %b%b%b %b%-55s%b %b(dupe)%b\n' \
                    "$C_YELLOW" "$i" "$S_RESET" "$C_WARNING" "$I_WARNING" "$S_RESET" \
                    "$C_YELLOW" "$entry" "$S_RESET" "$C_MUTED" "$S_RESET"
            else
                printf '  %b%2d%b %b%b%b %-55s %b%s%b\n' \
                    "$C_GREEN" "$i" "$S_RESET" "$C_SUCCESS" "$I_SUCCESS" "$S_RESET" \
                    "$entry" "$C_OVERLAY" "$cat" "$S_RESET"
            fi
        else
            # -- Known-OK missing dirs (created on demand)
            local known_ok=0
            case "$entry" in
                */cargo/bin | */go/bin | */gem/bin) known_ok=1 ;;
                */carapace/bin) known_ok=1 ;;
                */.nix-profile/bin) known_ok=1 ;;
                */cryptex* | */com.apple*) known_ok=1 ;;
            esac

            if [ "$known_ok" -eq 1 ]; then
                on_demand=$((on_demand + 1))
                printf '  %b%2d%b %b○%b %-55s %b%s (on-demand)%b\n' \
                    "$C_OVERLAY" "$i" "$S_RESET" "$C_MUTED" "$S_RESET" \
                    "$entry" "$C_OVERLAY" "$cat" "$S_RESET"
            else
                missing=$((missing + 1))
                printf '  %b%2d%b %b%b%b %b%-55s%b %b(missing)%b\n' \
                    "$C_RED" "$i" "$S_RESET" "$C_ERROR" "$I_ERROR" "$S_RESET" \
                    "$C_RED" "$entry" "$S_RESET" "$C_MUTED" "$S_RESET"
            fi
        fi
    done <<< "$entries"

    _separator
    printf '  %bTotal: %s%b  ' "$C_SUBTEXT" "$i" "$S_RESET"
    printf '%b%b %s valid%b  ' "$C_SUCCESS" "$I_SUCCESS" "$valid" "$S_RESET"
    printf '%b○ %s on-demand%b  ' "$C_OVERLAY" "$on_demand" "$S_RESET"
    if [ "$missing" -gt 0 ]; then
        printf '%b%b %s missing%b  ' "$C_RED" "$I_ERROR" "$missing" "$S_RESET"
    fi
    if [ "$dupes" -gt 0 ]; then
        printf '%b%b %s dupes%b' "$C_YELLOW" "$I_WARNING" "$dupes" "$S_RESET"
    fi
    printf '\n\n'
}

cmd_color() {
    _banner
    _section "${I_PALETTE} Colors"
    printf '  '
    for n in RED GREEN YELLOW BLUE MAUVE TEAL SKY PEACH LAVENDER; do eval "printf '%b██%b ' \"\$C_${n}\" '$S_RESET'"; done
    printf '\n\n  Truecolor: '
    for r in $(seq 0 8 255); do printf '\033[48;2;%d;50;200m \033[0m' "$r"; done
    printf '\n  Nerd Font: %s %s %s %s %s %s %s %s\n\n' "$I_TERMINAL" "$I_FOLDER" "$I_GIT" "$I_DOCKER" "$I_K8S" "$I_ROCKET" "$I_SHIELD" "$I_LIGHTNING"
}

cmd_diff() {
    if [ ! -d "${DOTFILES_DIR}/.git" ]; then
        _err "Dotfiles is not a git repo: ${DOTFILES_DIR}"
        return 1
    fi

    local ch
    ch="$(git -C "$DOTFILES_DIR" status --porcelain 2> /dev/null)"

    if [ -z "$ch" ]; then
        _ok "No uncommitted changes in dotfiles"
        return 0
    fi

    _banner
    _section "${I_GIT}  Dotfiles Changes"

    printf '  %b%s files changed%b\n\n' "$C_SUBTEXT" "$(echo "$ch" | wc -l | tr -d ' ')" "$S_RESET"

    if _has delta; then
        git -C "$DOTFILES_DIR" diff --color=always | delta
    elif _has bat; then
        git -C "$DOTFILES_DIR" diff --color=always | bat --style=plain
    else
        git -C "$DOTFILES_DIR" diff --color=always
    fi
}

cmd_log() {
    _banner
    _section "${I_FILE}  Logs"
    if [ -n "${ZSH_LOG_FILE:-}" ] && [ -f "$ZSH_LOG_FILE" ]; then
        _has bat && bat --style=plain "$ZSH_LOG_FILE" || tail -50 "$ZSH_LOG_FILE"
    else
        printf '  %bEnable: export ZSH_LOG_FILE=~/.local/state/zsh/shell.log%b\n' "$C_SUBTEXT" "$S_RESET"
        ZSH_NO_FASTFETCH=1 zsh -ic exit 2>&1 | tail -15
    fi
    printf '\n'
}

cmd_edit() {
    local t="${1:-}"
    [ -n "$t" ] && [ -e "${DOTFILES_DIR}/${t}" ] && "${EDITOR:-nvim}" "${DOTFILES_DIR}/${t}" || "${EDITOR:-nvim}" "$DOTFILES_DIR"
}
