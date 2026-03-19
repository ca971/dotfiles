#!/usr/bin/env zsh

[[ -n "${_ZSH_TOOLS_BREW_LOADED:-}" ]] && return 0

readonly _ZSH_TOOLS_BREW_LOADED=1

has "brew" || return 0

log_debug "Configuring brew"

[[ -f "${DOTFILES_DIR}/config/tools.d/brew.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/brew.zsh"

log_debug "brew configured"
