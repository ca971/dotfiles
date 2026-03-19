#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_JQ_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_JQ_LOADED=1
has "jq" || return 0
log_debug "Configuring jq"

[[ -f "${DOTFILES_DIR}/config/tools.d/jq.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/jq.zsh"

function jqfzf() { jq -r 'paths(scalars) | join(".")' "$1" | fzf --preview="jq '.{1}' $1" --header='Select JSON path'; }
function jqurl() { curl -sSL "$1" | jq "${2:-.}"; }

log_debug "jq configured"
