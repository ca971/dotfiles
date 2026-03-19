#!/usr/bin/env bash
cmd_link() {
    _banner
    _section "${I_BRANCH}  Symlinks"
    _ln() {
        mkdir -p "$(dirname "$2")" 2> /dev/null
        ln -sf "$1" "$2" > /dev/null 2>&1
        _ok "$(echo "$2" | sed "s|${HOME}|~|") → $(echo "$1" | sed "s|${DOTFILES_DIR}/||")"
    }
    [ -f "${DOTFILES_DIR}/shells/zsh/.zshenv" ] && _ln "${DOTFILES_DIR}/shells/zsh/.zshenv" "${HOME}/.zshenv"
    [ -f "${DOTFILES_DIR}/shells/bash/.bashrc" ] && _ln "${DOTFILES_DIR}/shells/bash/.bashrc" "${HOME}/.bashrc"
    [ -f "${DOTFILES_DIR}/shells/bash/.bash_profile" ] && _ln "${DOTFILES_DIR}/shells/bash/.bash_profile" "${HOME}/.bash_profile"
    [ -f "${DOTFILES_DIR}/shells/fish/config.fish" ] && _ln "${DOTFILES_DIR}/shells/fish/config.fish" "${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish"
    [ -f "${DOTFILES_DIR}/shells/nushell/env.nu" ] && _ln "${DOTFILES_DIR}/shells/nushell/env.nu" "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/env.nu"
    [ -f "${DOTFILES_DIR}/shells/nushell/config.nu" ] && _ln "${DOTFILES_DIR}/shells/nushell/config.nu" "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/config.nu"
    [ -f "${DOTFILES_DIR}/config/git/.gitconfig" ] && _ln "${DOTFILES_DIR}/config/git/.gitconfig" "${HOME}/.gitconfig"
    if _has nu; then
        local ND="${XDG_CONFIG_HOME:-${HOME}/.config}/nushell"
        mkdir -p "$ND" 2> /dev/null
        _has zoxide && zoxide init nushell --cmd cd > "${ND}/zoxide.nu" 2> /dev/null || touch "${ND}/zoxide.nu"
        _has atuin && atuin init nu --disable-up-arrow > "${ND}/atuin.nu" 2> /dev/null || touch "${ND}/atuin.nu"
        _has carapace && carapace _carapace nushell > "${ND}/carapace.nu" 2> /dev/null || touch "${ND}/carapace.nu"
        _ok "Nushell inits"
    fi
    printf '\n  %b%b Done%b\n\n' "${C_SUCCESS}${S_BOLD}" "$I_SUCCESS" "$S_RESET"
}
cmd_unlink() {
    _banner
    _section "${I_BRANCH}  Removing"
    for t in "${HOME}/.zshenv" "${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.gitconfig" "${XDG_CONFIG_HOME:-${HOME}/.config}/fish/config.fish" "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/config.nu" "${XDG_CONFIG_HOME:-${HOME}/.config}/nushell/env.nu"; do [ -L "$t" ] && {
        rm -f "$t"
        _warn "$(echo "$t" | sed "s|${HOME}|~|")"
    }; done
    printf '\n  %b%b Done%b\n\n' "${C_SUCCESS}${S_BOLD}" "$I_SUCCESS" "$S_RESET"
}
