#!/usr/bin/env bash
cmd_tools() {
    _banner
    _section "${I_SEARCH}  Tools"
    _tr() {
        local t="$1" i="$2"
        if _has "$t"; then
            local v
            v=$("$t" --version 2> /dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
            printf '  %s %b%-16s%b %b%b%b %b%s%b\n' "$i" "$C_TEXT" "$t" "$S_RESET" "$C_SUCCESS" "$I_SUCCESS" "$S_RESET" "$C_SUBTEXT" "${v:-n/a}" "$S_RESET"
        else printf '  %s %b%-16s ○%b\n' "$i" "$C_MUTED" "$t" "$S_RESET"; fi
    }
    printf '\n  %b%b Essential%b\n' "${S_BOLD}${C_MAUVE}" "$I_STAR" "$S_RESET"
    for t in git nvim starship fzf eza bat fd rg zoxide delta atuin mise; do _tr "$t" "$I_PACKAGE"; done
    printf '\n  %b%b DevOps%b\n' "${S_BOLD}${C_BLUE}" "$I_DOCKER" "$S_RESET"
    for t in docker podman kubectl lazygit lazydocker direnv; do _tr "$t" "$I_DOCKER"; done
    printf '\n  %b%b Utilities%b\n' "${S_BOLD}${C_TEAL}" "$I_LIGHTNING" "$S_RESET"
    for t in btop dust duf yazi carapace navi fastfetch just gh topgrade thefuck tldr most gpg; do _tr "$t" "$I_LIGHTNING"; done
    printf '\n'
}
