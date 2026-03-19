#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_HELM_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_HELM_LOADED=1
has "helm" || return 0
log_debug "Configuring helm"
[[ -f "${DOTFILES_DIR}/config/tools.d/helm.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/helm.zsh"
function helm-fzf() { has "fzf" && helm list --all-namespaces -o json 2>/dev/null | jq -r '.[] | "\(.name)\t\(.namespace)\t\(.status)\t\(.chart)"' | fzf --header='Helm releases' --delimiter='\t' || helm list; }
log_debug "helm configured"
