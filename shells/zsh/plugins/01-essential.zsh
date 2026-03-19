#!/usr/bin/env zsh
# ============================================================================
# @file        plugins/01-essential.zsh
# @description Essential ZSH plugins that provide core shell enhancements.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @depends     plugins/00-zinit-bootstrap.zsh
# @changelog   1.1.0 — Added OMZL::functions.zsh to fix omz_urlencode
#              dependency required by termsupport.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_PLUGINS_ESSENTIAL_LOADED:-}" ]] && return 0
readonly _ZSH_PLUGINS_ESSENTIAL_LOADED=1

log_debug "Loading essential plugins"

# ============================================================================
# OMZ Libraries — Selective loading of Oh-My-Zsh core utilities
# ============================================================================

# @description  Load select OMZ library files as snippets.
#               IMPORTANT: functions.zsh MUST be loaded BEFORE termsupport.zsh
#               because termsupport depends on omz_urlencode() defined in
#               functions.zsh.
zinit for \
  OMZL::functions.zsh \
  OMZL::clipboard.zsh \
  OMZL::termsupport.zsh \
  OMZL::directories.zsh

# ============================================================================
# Environment & Path Enhancement
# ============================================================================

# @description  256-color terminal support and color utilities.
zinit ice wait"0" lucid atload"
  [[ -n \"\${LS_COLORS:-}\" ]] || eval \"\$(dircolors -b 2>/dev/null)\"
"
zinit light chrissicool/zsh-256color

# ============================================================================
# Utility Plugins
# ============================================================================

# @description  Enhanced sudo plugin — press Esc twice to add sudo
zinit ice wait"0" lucid
zinit snippet OMZP::sudo

# @description  Universal archive extraction command
zinit ice wait"1" lucid
zinit snippet OMZP::extract

# @description  Base64 encode/decode convenience functions
zinit ice wait"1" lucid
zinit snippet OMZP::encode64

# @description  URL encoding/decoding functions
zinit ice wait"1" lucid
zinit snippet OMZP::urltools

# @description  Colored man pages
zinit ice wait"1" lucid
zinit snippet OMZP::colored-man-pages

# ============================================================================
# Safe Paste — Prevent accidental execution of pasted commands
# ============================================================================

zinit ice wait"0" lucid
zinit snippet OMZP::safe-paste

# ============================================================================
# Magic Enter — Execute commands on empty Enter press
# ============================================================================

zinit ice wait"0" lucid atload"
  typeset -g MAGIC_ENTER_GIT_COMMAND='git status -sb && echo \"\" && eza --icons --group-directories-first 2>/dev/null || ls'
  typeset -g MAGIC_ENTER_OTHER_COMMAND='eza --icons --group-directories-first 2>/dev/null || ls -la'
"
zinit snippet OMZP::magic-enter

log_debug "Essential plugins loaded"
