#!/usr/bin/env bash
cmd_shells() {
    _banner
    _section "${I_TERMINAL}  Shells"
    printf '  %b%-12s %-12s %-12s %s%b\n' "${S_BOLD}${C_TEXT}" "SHELL" "INSTALLED" "LINKED" "CONFIG" "$S_RESET"
    _separator
    _sr() {
        local n="$1" i="$2" l="$3" c="$4"
        local ii ll
        _has "$n" && ii="${C_SUCCESS}${I_SUCCESS} yes${S_RESET}" || ii="${C_MUTED}○ no${S_RESET}"
        [ -L "$l" ] && ll="${C_SUCCESS}${I_SUCCESS} yes${S_RESET}" || ll="${C_MUTED}○ no${S_RESET}"
        printf '  %b%s %-10s%b %b %b %b%s%b\n' "$C_TEXT" "$i" "$n" "$S_RESET" "$ii" "$ll" "$C_OVERLAY" "$c" "$S_RESET"
    }
    _sr zsh "" "${HOME}/.zshenv" "shells/zsh/"
    _sr bash "" "${HOME}/.bashrc" "shells/bash/"
    _sr fish "󰈺" "${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish" "shells/fish/"
    _sr nu ">" "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/config.nu" "shells/nushell/"
    printf '\n  %bDefault: %b%s%b\n\n' "$C_SUBTEXT" "$C_TEXT" "$(basename "${SHELL:-?}")" "$S_RESET"
}
