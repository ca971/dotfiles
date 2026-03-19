#!/usr/bin/env bash
cmd_git_sign() {
    local action="${1:-info}"
    case "$action" in
        info) zsh -ic 'git-signing-info' ;;
        ssh) zsh -ic "git-signing-ssh ${2:-}" ;;
        off) zsh -ic 'git-signing-off' ;;
        verify) zsh -ic "git-verify ${2:-}" ;;
        trust) zsh -ic "git-trust ${2:-} ${3:-}" ;;
        *)
            printf '\n  %b%b  Git Signing%b\n' "${S_BOLD}${C_TEXT}" "$I_SHIELD" "$S_RESET"
            printf '    %binfo%b | %bssh%b | %boff%b | %bverify%b [ref] | %btrust%b <email> <key>\n\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
            ;;
    esac
}
