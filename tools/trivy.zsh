#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_TRIVY_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_TRIVY_LOADED=1
has "trivy" || return 0
log_debug "Configuring trivy"
function trivy-scan() { local img; has "fzf" && img=$(docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | fzf --header='Scan image') || { docker images; printf "Image: "; read -r img; }; [[ -n "$img" ]] && trivy image "$img"; }
log_debug "trivy configured"
