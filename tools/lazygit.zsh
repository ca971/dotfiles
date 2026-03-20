#!/usr/bin/env zsh
# ============================================================================
# @file        tools/lazygit.zsh
# @description Lazygit, Lazydocker, Lazyssh — TUI integrations.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_LAZYGIT_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_LAZYGIT_LOADED=1

has_any "lazygit" "lazydocker" "lazyssh" || return 0
log_debug "Configuring lazy* tools"


if has "lazygit"; then
  function lg-repo()   { lazygit --path "${1:-.}"; }
  function lg-log()    { lazygit log; }
  function lg-branch() { lazygit branch; }
fi

function lazy() {
  if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    has "lazygit" && lazygit
  elif has "lazydocker" && ${CONTAINER_RUNTIME:-docker} info &>/dev/null 2>&1; then
    lazydocker
  elif has "lazygit"; then
    lazygit
  fi
}

log_debug "lazy* configured"
