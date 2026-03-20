#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_AGE_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_AGE_LOADED=1
has "age" || return 0
log_debug "Configuring age"


function age-encrypt()  { local f="${1:?Usage: age-encrypt <file>}"; age -p -o "${f}.age" "$f" && log_info "Encrypted: ${f}.age"; }
function age-decrypt()  { local f="${1:?Usage: age-decrypt <file.age>}"; age -d "$f"; }
function age-keygen()   { local k="${1:-${HOME}/.config/age/key.txt}"; mkdir -p "$(dirname "$k")" 2>/dev/null; age-keygen -o "$k" 2>/dev/null && chmod 600 "$k" && log_info "Key: $k"; }

log_debug "age configured"
