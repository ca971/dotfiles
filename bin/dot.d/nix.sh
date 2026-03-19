#!/usr/bin/env bash
# ============================================================================
# @file        bin/dot.d/nix.sh
# @description Nix package manager management.
# @version     1.0.0
# ============================================================================

cmd_nix() {
    local action="${1:-}"
    shift 2> /dev/null || true

    case "$action" in
        info) zsh -ic 'nix-info' ;;
        dev) zsh -ic 'nix-dev' ;;
        install) zsh -ic 'nix-install-env' ;;
        update) zsh -ic 'nix-flake-update' ;;
        rebuild) zsh -ic 'nix-rebuild' ;;
        search) zsh -ic "nix-search ${1:-}" ;;
        list) zsh -ic 'nix-list' ;;
        clean) zsh -ic 'nix-clean' ;;
        shell) zsh -ic "nix-dev-shell ${1:-}" ;;
        flake) zsh -ic 'nix-flake-info' ;;
        audit) zsh -ic 'nix-audit' ;;
        edit) zsh -ic 'nix-edit' ;;
        *)
            printf '\n  %b%b  ❄️  Nix Management%b\n\n' "$S_BOLD" "$C_TEXT" "$S_RESET"
            printf '    %binfo%b            Nix installation info\n' "$C_TEAL" "$S_RESET"
            printf '    %bdev%b             Enter dotfiles dev shell\n' "$C_TEAL" "$S_RESET"
            printf '    %binstall%b         Install all packages from flake\n' "$C_TEAL" "$S_RESET"
            printf '    %bupdate%b          Update flake inputs\n' "$C_TEAL" "$S_RESET"
            printf '    %brebuild%b         Update + reinstall environment\n' "$C_TEAL" "$S_RESET"
            printf '    %bsearch%b %b<pkg>%b   Search nixpkgs\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET"
            printf '    %blist%b            List installed packages\n' "$C_TEAL" "$S_RESET"
            printf '    %bclean%b           Garbage collect store\n' "$C_TEAL" "$S_RESET"
            printf '    %bshell%b %b<lang>%b   Dev shell (python|node|rust|go)\n' "$C_TEAL" "$S_RESET" "$C_PEACH" "$S_RESET"
            printf '    %bflake%b           Show flake info\n' "$C_TEAL" "$S_RESET"
            printf '    %baudit%b           Security audit\n' "$C_TEAL" "$S_RESET"
            printf '    %bedit%b            Edit nix.conf\n\n' "$C_TEAL" "$S_RESET"
            ;;
    esac
}
