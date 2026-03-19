#!/usr/bin/env bash
# @file bin/dot.d/status.sh — Quick dashboard

cmd_status() {
    _banner
    _section "${I_INFO}  Status Dashboard"

    printf '  %b%b%b  Repository%b\n' "$S_BOLD" "$C_TEXT" "$I_GIT" "$S_RESET"
    if [ -d "${DOTFILES_DIR}/.git" ]; then
        local branch hash dirty ahead behind
        branch="$(cd "$DOTFILES_DIR" && git branch --show-current 2> /dev/null || echo '?')"
        hash="$(cd "$DOTFILES_DIR" && git rev-parse --short HEAD 2> /dev/null || echo '?')"
        dirty="$(cd "$DOTFILES_DIR" && git status --porcelain 2> /dev/null | wc -l | tr -d ' ')"
        ahead="$(cd "$DOTFILES_DIR" && git rev-list --count @{upstream}..HEAD 2> /dev/null || echo 0)"
        behind="$(cd "$DOTFILES_DIR" && git rev-list --count HEAD..@{upstream} 2> /dev/null || echo 0)"
        printf '    Branch:  %b%s%b %b(%s)%b\n' "$C_GREEN" "$branch" "$S_RESET" "$C_OVERLAY" "$hash" "$S_RESET"
        [ "${dirty:-0}" -gt 0 ] && printf '    Changes: %b%s uncommitted%b\n' "$C_YELLOW" "$dirty" "$S_RESET" || printf '    Changes: %bclean%b\n' "$C_SUCCESS" "$S_RESET"
        [ "${ahead:-0}" -gt 0 ] && printf '    Push:    %b%s ahead%b\n' "$C_PEACH" "$ahead" "$S_RESET"
        [ "${behind:-0}" -gt 0 ] && printf '    Pull:    %b%s behind%b\n' "$C_SKY" "$behind" "$S_RESET"
    else
        printf '    %bNot a git repo%b\n' "$C_MUTED" "$S_RESET"
    fi

    printf '\n  %b%b%s Theme%b\n' "$S_BOLD" "$C_TEXT" "$I_PALETTE" "$S_RESET"
    printf '    Active:  %b%s%b\n' "$C_MAUVE" "$(basename "${STARSHIP_CONFIG:-unknown}" .toml | sed 's/starship-//')" "$S_RESET"

    printf '\n  %b%b%b  SSOT%b\n' "$S_BOLD" "$C_TEXT" "$I_SETTINGS" "$S_RESET"
    local gf="${DOTFILES_DIR}/generated/aliases.zsh"
    if [ -f "$gf" ]; then
        local fe
        fe=$(_stat_mtime "$gf")
        if [ -n "$fe" ]; then
            local ad=$((($(date +%s) - fe) / 86400))
            [ "$ad" -eq 0 ] && printf '    Generated: %btoday%b\n' "$C_SUCCESS" "$S_RESET" \
                || [ "$ad" -lt 7 ] && printf '    Generated: %b%sd ago%b\n' "$C_GREEN" "$ad" "$S_RESET" \
                || printf '    Generated: %b%sd ago %b run: dot generate%b\n' "$C_YELLOW" "$ad" "$I_WARNING" "$S_RESET"
        fi
    else
        printf '    %bmissing — dot generate%b\n' "$C_RED" "$S_RESET"
    fi

    printf '\n  %b%b%b  Environment%b\n' "$S_BOLD" "$C_TEXT" "$I_TERMINAL" "$S_RESET"
    printf '    Shell: %b%s%b  Term: %b%s%b\n\n' "$C_TEAL" "$(_detect_shell)" "$S_RESET" "$C_LAVENDER" "${TERM_PROGRAM:-?}" "$S_RESET"
}
