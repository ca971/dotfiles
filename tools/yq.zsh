#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_YQ_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_YQ_LOADED=1
has "yq" || return 0
log_debug "Configuring yq"


function yaml2json() { yq -o json "${1:?Usage: yaml2json <file>}"; }
function json2yaml() { yq -P "${1:?Usage: json2yaml <file>}"; }
function toml2json() { yq -o json -p toml "${1:?Usage: toml2json <file>}"; }

log_debug "yq configured"
