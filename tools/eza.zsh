#!/usr/bin/env zsh
# ============================================================================
# @file        tools/eza.zsh
# @description Eza (ls replacement) — auto-setup + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_EZA_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_EZA_LOADED=1

has "eza" || return 0
log_debug "Configuring eza"


# ── Hyperlinks (terminal-aware) ──────────────────────────────────────────────
case "${ZSH_TERMINAL:-}" in
  ghostty|wezterm|kitty|iterm) export EZA_HYPERLINK=1 ;;
  *)                           export EZA_HYPERLINK=0 ;;
esac

# ── Functions ────────────────────────────────────────────────────────────────
function ltree()  { local depth="${1:-2}"; [[ "$1" =~ ^[0-9]+$ ]] && shift; command eza --icons --tree --level="$depth" --color=always "$@"; }
function ltoday() { command eza --icons --long --sort=modified --reverse --color=always "$@" | head -20; }
function ldu()    { command eza --icons --long --total-size --sort=size --reverse --no-time --no-user --no-permissions --color=always "${1:-.}"; }
function lf() {
  if has "fzf" && has "bat"; then
    command eza --icons --oneline --color=always "$@" | \
      fzf --ansi --preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || cat {}' \
          --preview-window 'right:60%:wrap' --height '80%' --border
  else
    command eza --icons --color=always "$@"
  fi
}

log_debug "eza configured"
