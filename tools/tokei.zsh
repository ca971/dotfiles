#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_TOKEI_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_TOKEI_LOADED=1
has "tokei" || return 0
log_debug "Configuring tokei"

[[ -f "${DOTFILES_DIR}/config/tools.d/tokei.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/tokei.zsh"

log_debug "tokei configured"
