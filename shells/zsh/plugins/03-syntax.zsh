#!/usr/bin/env zsh
# ============================================================================
# @file        plugins/03-syntax.zsh
# @description Syntax highlighting, autosuggestions, and visual enhancements.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @note        LOADING ORDER MATTERS:
#              1. fast-syntax-highlighting
#              2. zsh-autosuggestions
#              3. zsh-history-substring-search
#
# @depends     plugins/00-zinit-bootstrap.zsh, generated/highlights.zsh
# @changelog   1.1.0 — Fixed atload quoting issues causing eval errors.
#              Fixed zsh-you-should-use repo name (Aquilina not Aqworter).
#              Moved autosuggest-accept bindkey inside atload.
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_PLUGINS_SYNTAX_LOADED:-}" ]] && return 0
readonly _ZSH_PLUGINS_SYNTAX_LOADED=1

log_debug "Loading syntax enhancement plugins"

# ============================================================================
# Fast Syntax Highlighting
# ============================================================================

# @description  Load SSOT highlight styles before the plugin initializes,
#               then load the fast-syntax-highlighting plugin.
zinit ice wait"0" lucid atinit"
  local _hl_file=\"\${ZDOTDIR}/generated/highlights.zsh\"
  [[ -f \"\$_hl_file\" ]] && source \"\$_hl_file\"
"
zinit light zdharma-continuum/fast-syntax-highlighting

# ============================================================================
# Autosuggestions
# ============================================================================

# @description  zsh-autosuggestions shows command suggestions (ghost text).
#               All keybindings are set inside atload to ensure the plugin
#               and its widgets are already registered.
zinit ice wait"0" lucid atload"
  # -- Keybindings (widgets are now available)
  bindkey '^ ' autosuggest-accept 2>/dev/null || true
  bindkey '^[[C' forward-char 2>/dev/null || true

  # -- Configuration
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  ZSH_AUTOSUGGEST_USE_ASYNC=1
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
    \$ZSH_AUTOSUGGEST_CLEAR_WIDGETS
    bracketed-paste
    up-line-or-beginning-search
    down-line-or-beginning-search
  )
"
zinit light zsh-users/zsh-autosuggestions

# ============================================================================
# History Substring Search
# ============================================================================

# @description  Must load AFTER both syntax-highlighting and autosuggestions.
zinit ice wait"0" lucid atload"
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#313244,fg=#a6e3a1,bold'
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#313244,fg=#f38ba8,bold'
  HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'
  HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
  HISTORY_SUBSTRING_SEARCH_FUZZY=1

  bindkey '^[[A' history-substring-search-up 2>/dev/null || true
  bindkey '^[[B' history-substring-search-down 2>/dev/null || true
  bindkey '^P' history-substring-search-up
  bindkey '^N' history-substring-search-down
"
zinit light zsh-users/zsh-history-substring-search

# ============================================================================
# Autopair — Auto-close brackets and quotes
# ============================================================================

zinit ice wait"1" lucid
zinit light hlissner/zsh-autopair

# ============================================================================
# You Should Use — Alias reminder
# ============================================================================

# @description  Reminds you to use aliases. Disabled hardcore mode.
#               Set YSU_MODE=0 in local/local.zsh to disable completely.
# zinit ice wait"1" lucid atload"
#   export YSU_MESSAGE_POSITION='after'
#   export YSU_MIN_ALIAS_LENGTH=3
#
#   # -- CRITICAL: unset, do NOT set to 0 (plugin checks -n, not value)
#   unset YSU_HARDCORE
#
#   # -- Ignore aliases that shadow the original command name
#   # (e.g., alias ls='eza ...' — typing ls IS using the alias)
#   export YSU_IGNORED_ALIASES=(ls la ll lla cat top du df vi vim)
# "
# zinit light MichaelAquilina/zsh-you-should-use

log_debug "Syntax enhancement plugins loaded"
