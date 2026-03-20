#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_DIFFTASTIC_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_DIFFTASTIC_LOADED=1
has "difft" || return 0
log_debug "Configuring difftastic"


function gdft() { GIT_EXTERNAL_DIFF=difft git diff "$@"; }
function gdft-staged() { GIT_EXTERNAL_DIFF=difft git diff --staged "$@"; }

log_debug "difftastic configured"
