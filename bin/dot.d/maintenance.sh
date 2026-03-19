#!/usr/bin/env bash
cmd_update() {
    _banner
    _section "${I_LOADING}  Update"
    [ -d "${DOTFILES_DIR}/.git" ] && {
        (cd "$DOTFILES_DIR" && git pull --rebase --autostash 2>&1 | sed 's/^/     /')
        _ok "Pulled"
    }
    source "${DOT_DIR}/generate.sh"
    cmd_generate all
    printf '\n  %b%b Done%b\n\n' "${C_SUCCESS}${S_BOLD}" "$I_SUCCESS" "$S_RESET"
}
cmd_upgrade() {
    cmd_update
    _section "${I_ROCKET}  Upgrade"
    _has zsh && {
        zsh -c "for f in ${DOTFILES_DIR}/**/*.zsh(N); do zcompile \"\$f\" 2>/dev/null; done" 2> /dev/null
        _ok "Compiled"
    }
    printf '\n  %b%b Done — exec \$SHELL%b\n\n' "${C_SUCCESS}${S_BOLD}" "$I_SUCCESS" "$S_RESET"
}
cmd_clean() {
    _banner
    _section "${I_LOADING}  Clean"
    local c
    c=$(find "$DOTFILES_DIR" \( -name "*.zwc" -o -name "*.zwc.old" \) 2> /dev/null | wc -l | tr -d ' ')
    find "$DOTFILES_DIR" \( -name "*.zwc" -o -name "*.zwc.old" \) -delete 2> /dev/null
    _ok "Removed $c files"
    [ -d "${DOTFILES_DIR}/cache" ] && {
        rm -rf "${DOTFILES_DIR}/cache/"* 2> /dev/null
        _ok "Cache cleared"
    }
    printf '\n'
}
cmd_backup() {
    _banner
    _section "${I_SHIELD}  Backup"
    local bd="${HOME}/.dotfiles-backups" bf
    mkdir -p "$bd"
    bf="${bd}/dotfiles-$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$bf" --exclude='.git' --exclude='*.zwc' --exclude='cache/*' --exclude='local/secrets.*' -C "$(dirname "$DOTFILES_DIR")" "$(basename "$DOTFILES_DIR")" 2> /dev/null
    _ok "Backup: $bf"
    printf '\n'
}
cmd_restore() {
    _banner
    _section "${I_SHIELD}  Restore"
    local bd="${HOME}/.dotfiles-backups" bf="${1:-}"
    [ -z "$bf" ] && _has fzf && bf=$(ls -1t "$bd"/dotfiles-*.tar.gz 2> /dev/null | fzf --header="${I_SHIELD} Select" --preview="tar -tzf {} | head -30" --height='50%')
    [ -z "$bf" ] || [ ! -f "$bf" ] && {
        _err "Not found"
        return 1
    }
    _warn "Will overwrite!"
    printf '  [y/N]: '
    read -r c
    [ "$c" = "y" ] && {
        cmd_backup
        tar -xzf "$bf" -C "$(dirname "$DOTFILES_DIR")"
        _ok "Restored"
    }
}
