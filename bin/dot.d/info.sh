#!/usr/bin/env bash
# @file bin/dot.d/info.sh — System & dotfiles info

cmd_info() {
    _banner
    _section "$(_os_icon)  Dotfiles"

    local git_info="${C_MUTED}N/A${S_RESET}"
    if [ -d "${DOTFILES_DIR}/.git" ]; then
        local h b d=""
        h="$(cd "$DOTFILES_DIR" && git rev-parse --short HEAD 2> /dev/null)"
        b="$(cd "$DOTFILES_DIR" && git branch --show-current 2> /dev/null)"
        (cd "$DOTFILES_DIR" && git diff --quiet 2> /dev/null) || d=" ${C_YELLOW}●${S_RESET}"
        git_info="${C_GREEN}${h}${S_RESET} ${C_SUBTEXT}(${b})${S_RESET}${d}"
    fi

    _kv "${I_FOLDER}  Root:" "${C_BLUE}${DOTFILES_DIR}${S_RESET}"
    _kv "${I_PACKAGE}  Version:" "${C_MAUVE}${VERSION}${S_RESET}"
    _kv "${I_GIT}  Git:" "$git_info"
    _kv "${I_PALETTE} Theme:" "${C_PEACH}$(basename "${STARSHIP_CONFIG:-unknown}" .toml | sed 's/starship-//')${S_RESET}"

    _section "${I_TERMINAL}  System"
    _kv "${I_TERMINAL}  Shell:" "${C_TEAL}$(_detect_shell)${S_RESET}"
    _kv "$(_os_icon)  Platform:" "${C_SKY}$(uname -s) ($(uname -m))${S_RESET}"
    _kv "${I_CODE}  Terminal:" "${C_LAVENDER}${TERM_PROGRAM:-${TERM:-unknown}}${S_RESET}"

    _section "${I_STAR}  Shells"
    local s ic v
    for s in zsh bash fish nu; do
        case "$s" in zsh) ic="" ;; bash) ic="" ;; fish) ic="󰈺" ;; nu) ic=">" ;; esac
        if _has "$s"; then
            v=$("$s" --version 2> /dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            printf '  %b %s  %-8s %b%s%b\n' "${C_SUCCESS}${I_SUCCESS}${S_RESET}" "$ic" "$s" "$C_SUBTEXT" "${v:-}" "$S_RESET"
        else
            printf '  %b○  %s  %s%b\n' "$C_MUTED" "$ic" "$s" "$S_RESET"
        fi
    done
    printf '\n'
}
