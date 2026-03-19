#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_ACT_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ACT_LOADED=1
has "act" || return 0
log_debug "Configuring act"
[[ -f "${DOTFILES_DIR}/config/tools.d/act.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/act.zsh"
function act-fzf() { has "fzf" && { local w=$(find .github/workflows -name "*.yml" -o -name "*.yaml" 2>/dev/null | fzf --header='Workflow' --preview='bat --color=always {} 2>/dev/null'); [[ -n "$w" ]] && act -W "$w"; } || act; }
log_debug "act configured"
