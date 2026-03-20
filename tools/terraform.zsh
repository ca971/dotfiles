#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_TERRAFORM_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_TERRAFORM_LOADED=1
has "terraform" || has "tofu" || return 0
log_debug "Configuring terraform"
has "tofu" && ! has "terraform" && alias terraform="tofu"
function tf-ws() { has "fzf" && terraform workspace list | sed 's/^[* ]*//' | fzf --header='Workspace' | xargs terraform workspace select || terraform workspace list; }
log_debug "terraform configured"
