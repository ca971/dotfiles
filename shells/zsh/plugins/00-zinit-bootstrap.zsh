#!/usr/bin/env zsh
# ============================================================================
# @file        plugins/00-zinit-bootstrap.zsh
# @description Zinit plugin manager bootstrap and initialization. Handles
#              automatic installation of Zinit if not present, configures
#              Zinit directories to be XDG-compliant, loads Zinit annexes.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @see         https://github.com/zdharma-continuum/zinit
# @depends     lib/logging.zsh, core/00-xdg.zsh
# @changelog   1.1.0 — Fixed ZINIT hash configuration. The ZINIT associative
#              array must only be set BEFORE sourcing zinit.zsh, and must use
#              individual assignments (not bulk declare).
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_PLUGINS_ZINIT_BOOTSTRAP_LOADED:-}" ]] && return 0
readonly _ZSH_PLUGINS_ZINIT_BOOTSTRAP_LOADED=1

log_debug "Bootstrapping Zinit plugin manager"

# ============================================================================
# Zinit Directory Configuration — XDG-compliant
# ============================================================================

# @description  Root directory for Zinit installation and data
ZINIT_HOME="${ZINIT_HOME:-${XDG_DATA_HOME}/zinit}"

# @description  Zinit internal directory structure.
#               IMPORTANT: Declare ZINIT as a regular associative array
#               with individual key assignments. Bulk assignment with
#               declare -gA ZINIT=(...) causes "invalid subscript range"
#               on some ZSH versions.
typeset -gA ZINIT
ZINIT[HOME_DIR]="${ZINIT_HOME}"
ZINIT[BIN_DIR]="${ZINIT_HOME}/zinit.git"
ZINIT[PLUGINS_DIR]="${ZINIT_HOME}/plugins"
ZINIT[SNIPPETS_DIR]="${ZINIT_HOME}/snippets"
ZINIT[COMPLETIONS_DIR]="${ZINIT_HOME}/completions"
ZINIT[SERVICES_DIR]="${ZINIT_HOME}/services"
ZINIT[ZCOMPDUMP_PATH]="${ZSH_CACHE_DIR}/zcompdump-${ZSH_VERSION}"
ZINIT[COMPINIT_OPTS]="-C"
ZINIT[MUTE_WARNINGS]=0
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1

# ============================================================================
# Zinit Auto-Installation
# ============================================================================

# @description  Automatically install Zinit if not found.
if [[ ! -f "${ZINIT[BIN_DIR]}/zinit.zsh" ]]; then
  log_info "Zinit not found — installing..."

  command mkdir -p "${ZINIT_HOME}" || {
    log_error "Failed to create Zinit directory: %s" "${ZINIT_HOME}"
    return 1
  }

  if command -v git &>/dev/null; then
    command git clone --depth=1 \
      "https://github.com/zdharma-continuum/zinit.git" \
      "${ZINIT[BIN_DIR]}" 2>/dev/null && \
      log_success "Zinit installed successfully" || {
        log_error "Failed to clone Zinit repository"
        return 1
      }
  else
    log_error "Git is required to install Zinit"
    return 1
  fi
fi

# ============================================================================
# Load Zinit
# ============================================================================

if [[ -f "${ZINIT[BIN_DIR]}/zinit.zsh" ]]; then
  source "${ZINIT[BIN_DIR]}/zinit.zsh"

  autoload -Uz _zinit
  (( ${+_comps} )) && _comps[zinit]=_zinit

  log_debug "Zinit loaded from %s" "${ZINIT[BIN_DIR]}"
else
  log_error "Zinit binary not found at %s — plugins will not load" "${ZINIT[BIN_DIR]}/zinit.zsh"
  return 1
fi

# ============================================================================
# Zinit Annexes — Extended functionality
# ============================================================================

log_debug "Loading Zinit annexes"

zinit light-mode for \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust \
  zdharma-continuum/zinit-annex-default-ice

log_debug "Zinit bootstrap complete"
