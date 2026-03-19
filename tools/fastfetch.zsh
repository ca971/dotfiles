#!/usr/bin/env zsh
# ============================================================================
# @file        tools/fastfetch.zsh
# @description Fastfetch (system info display).
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_FASTFETCH_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_FASTFETCH_LOADED=1

has "fastfetch" || return 0
log_debug "Configuring fastfetch"

[[ -f "${DOTFILES_DIR}/config/tools.d/fastfetch.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/fastfetch.zsh"

function sysinfo-full() { fastfetch --show-errors --multithreading true; }
function sysinfo-json() { fastfetch --format json 2>/dev/null; }
function hwinfo()       { fastfetch --structure CPU:GPU:Memory:Disk:Battery --logo none; }
function shellinfo()    { fastfetch --structure Title:OS:Kernel:Shell:Terminal:TerminalFont --logo none; }

log_debug "fastfetch configured"
