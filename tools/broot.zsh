#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_BROOT_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_BROOT_LOADED=1
has "broot" || return 0
log_debug "Configuring broot"

[[ -f "${DOTFILES_DIR}/config/tools.d/broot.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/broot.zsh"

local _broot_launcher="${XDG_CONFIG_HOME:-${HOME}/.config}/broot/launcher/bash/br"
[[ -f "$_broot_launcher" ]] && source "$_broot_launcher"

log_debug "broot configured"
