#!/usr/bin/env bash
# @file bin/dot.d/ssh.sh — SSH management (delegates to ZSH)

cmd_ssh() {
    local action="${1:-}"
    shift 2> /dev/null || true

    case "$action" in
        info) zsh -ic 'ssh-config-info' ;;
        keys) zsh -ic 'ssh-keys' ;;
        edit) zsh -ic "ssh-config-edit ${1:-}" ;;
        add) zsh -ic "ssh-config-add ${1:-personal}" ;;
        test) zsh -ic "ssh-test ${1:-}" ;;
        rebuild) zsh -ic 'ssh-config-rebuild' ;;
        load) zsh -ic 'ssh-keys-load' ;;
        generate) zsh -ic "ssh-key-generate ${1:-}" ;;
        delete) zsh -ic "ssh-key-delete ${1:-}" ;;
        copy) zsh -ic "ssh-key-copy ${1:-}" ;;
        fix) zsh -ic 'ssh-fix-perms' ;;
        agent) zsh -ic 'ssh-agent-info' ;;
        backup) zsh -ic 'ssh-backup' ;;
        restore) zsh -ic "ssh-restore ${1:-}" ;;
        backups) zsh -ic 'ssh-backup-list' ;;
        audit) zsh -ic 'ssh-audit' ;;
        age) zsh -ic "ssh-key-age ${1:-365}" ;;
        rotate) zsh -ic "ssh-key-rotate ${1:-}" ;;
        scan) zsh -ic 'git-secrets-scan' ;;
        *)
            printf '\n  %b%b%b  SSH Management%b\n\n' "$S_BOLD" "$C_TEXT" "$I_SHIELD" "$S_RESET"
            printf '    %binfo%b      Config overview       %bkeys%b      List keys\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
            printf '    %bedit%b      Edit config           %badd%b       Add host\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
            printf '    %btest%b      Test connectivity      %brebuild%b   Rebuild config\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
            printf '    %bload%b      Load keys to agent    %bgenerate%b  New key pair\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
            printf '    %bdelete%b    Delete key pair       %bcopy%b      Copy pub key\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
            printf '    %bfix%b       Fix permissions       %bagent%b     Agent status\n\n' "$C_TEAL" "$S_RESET" "$C_TEAL" "$S_RESET"
            printf '    %bbackup%b     Encrypted key backup\n' "$C_TEAL" "$S_RESET"
            printf '    %brestore%b    Restore from backup\n' "$C_TEAL" "$S_RESET"
            printf '    %bbackups%b    List available backups\n' "$C_TEAL" "$S_RESET"
            printf '    %baudit%b      Security audit\n' "$C_TEAL" "$S_RESET"
            printf '    %bage%b          Key age report\n' "$C_TEAL" "$S_RESET"
            printf '    %brotate%b       Rotate an old key\n' "$C_TEAL" "$S_RESET"
            ;;
    esac
}
