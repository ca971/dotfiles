#!/usr/bin/env zsh
# ============================================================================
# @file        tools/btop.zsh
# @description Btop (system monitor) — aliases + sysstat function.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_BTOP_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_BTOP_LOADED=1

has "btop" || return 0
log_debug "Configuring btop"

[[ -f "${DOTFILES_DIR}/config/tools.d/btop.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/btop.zsh"

function sysstat() {
  printf "\n  📊 System Snapshot\n  ─────────────────────────────────\n"
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    printf "  CPU:     %s cores\n" "$(sysctl -n hw.ncpu 2>/dev/null)"
    printf "  Memory:  %sGB\n" "$(( $(sysctl -n hw.memsize 2>/dev/null) / 1073741824 ))"
  else
    printf "  CPU:     %s cores\n" "$(nproc 2>/dev/null)"
    printf "  Memory:  %s\n" "$(free -h 2>/dev/null | awk '/^Mem:/{print $3 "/" $2}')"
  fi
  printf "  Load:    %s\n" "$(uptime 2>/dev/null | awk -F'load averages?:' '{print $2}' | xargs)"
  printf "  ─────────────────────────────────\n\n"
}

log_debug "btop configured"
