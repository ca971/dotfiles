#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_SOPS_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_SOPS_LOADED=1
has "sops" || return 0
log_debug "Configuring sops"
[[ -f "${DOTFILES_DIR}/config/tools.d/sops.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/sops.zsh"
function sops-edit()    { sops "${1:?Usage: sops-edit <file>}"; }
function sops-encrypt() { sops --encrypt --in-place "${1:?File?}"; }
function sops-decrypt() { sops --decrypt "${1:?File?}"; }
log_debug "sops configured"
