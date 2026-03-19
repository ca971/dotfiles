#!/usr/bin/env zsh
# ============================================================================
# @file        core/00-xdg.zsh
# @description XDG Base Directory Specification implementation. Establishes
#              standard directory paths for configuration, data, cache, state,
#              and runtime files. Ensures all tools respect XDG conventions
#              to keep $HOME clean.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
# @see         https://specifications.freedesktop.org/basedir-spec/latest/
#
# @depends     lib/logging.zsh
# @changelog   1.1.0 — Removed ZINIT config (moved to plugins/00-zinit-bootstrap.zsh)
#              to avoid "assignment to invalid subscript range" error
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_XDG_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_XDG_LOADED=1

log_debug "Initializing XDG Base Directory paths"

# @description  Ensure DOTFILES_DIR is set (fallback)
export DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

# ============================================================================
# XDG Base Directories — Core Specification
# ============================================================================

# @description Base directory for user-specific configuration files
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

# @description Base directory for user-specific data files
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"

# @description Base directory for user-specific non-essential cached data
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"

# @description Base directory for user-specific state data (logs, history, etc.)
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"

# @description Base directory for user-specific runtime files (sockets, PIDs)
if [[ -z "${XDG_RUNTIME_DIR:-}" ]]; then
  if [[ -d "/run/user/${UID}" ]]; then
    export XDG_RUNTIME_DIR="/run/user/${UID}"
  else
    export XDG_RUNTIME_DIR="${TMPDIR:-/tmp}/runtime-${USER}"
    [[ -d "$XDG_RUNTIME_DIR" ]] || mkdir -p "$XDG_RUNTIME_DIR" && chmod 0700 "$XDG_RUNTIME_DIR"
  fi
fi

# @description User-specific executable files
export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"

# ============================================================================
# ZSH-Specific XDG Paths
# ============================================================================

# @description ZSH data directory (history, completions cache, etc.)
export ZSH_DATA_DIR="${XDG_DATA_HOME}/zsh"

# @description ZSH cache directory (compiled files, plugin cache)
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"

# @description ZSH state directory (session logs, undo history)
export ZSH_STATE_DIR="${XDG_STATE_HOME}/zsh"

# ============================================================================
# Zinit Paths — Exported as simple variables (NOT the ZINIT hash)
# The ZINIT associative array is configured in plugins/00-zinit-bootstrap.zsh
# AFTER Zinit is loaded. Setting it here causes "invalid subscript range".
# ============================================================================

# @description  Root directory for Zinit installation and data
export ZINIT_HOME="${XDG_DATA_HOME}/zinit"

# ============================================================================
# Tool-Specific XDG Overrides — Keep $HOME clean
# ============================================================================

# -- Less
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"

# -- GNU Readline
export INPUTRC="${XDG_CONFIG_HOME}/readline/inputrc"

# -- GNU Screen
export SCREENRC="${XDG_CONFIG_HOME}/screen/screenrc"

# -- Docker
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# -- GnuPG
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

# -- npm
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export NPM_CONFIG_CACHE="${XDG_CACHE_HOME}/npm"

# -- Node.js REPL history
export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node/repl_history"

# -- Python
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonstartup.py"
export PYTHON_HISTORY="${XDG_STATE_HOME}/python/history"
export PYTHONUSERBASE="${XDG_DATA_HOME}/python"
export PIPX_HOME="${XDG_DATA_HOME}/pipx"
export PIPX_BIN_DIR="${XDG_BIN_HOME}"

# -- Rust / Cargo
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"

# -- Go
export GOPATH="${XDG_DATA_HOME}/go"
export GOMODCACHE="${XDG_CACHE_HOME}/go/mod"

# -- Ruby / Bundler / Gem
export GEM_HOME="${XDG_DATA_HOME}/gem"
export GEM_SPEC_CACHE="${XDG_CACHE_HOME}/gem"
export BUNDLE_USER_CONFIG="${XDG_CONFIG_HOME}/bundle"
export BUNDLE_USER_CACHE="${XDG_CACHE_HOME}/bundle"
export BUNDLE_USER_PLUGIN="${XDG_DATA_HOME}/bundle"

# -- Wget
export WGETRC="${XDG_CONFIG_HOME}/wget/wgetrc"
alias wget='wget --hsts-file="${XDG_DATA_HOME}/wget/hsts"'

# -- Kubernetes
export KUBECONFIG="${XDG_CONFIG_HOME}/kube/config"

# -- Helm
export HELM_CONFIG_HOME="${XDG_CONFIG_HOME}/helm"
export HELM_DATA_HOME="${XDG_DATA_HOME}/helm"
export HELM_CACHE_HOME="${XDG_CACHE_HOME}/helm"

# -- Terraform
export TF_CLI_CONFIG_FILE="${XDG_CONFIG_HOME}/terraform/terraformrc"

# -- mise (runtime version manager)
export MISE_CONFIG_DIR="${XDG_CONFIG_HOME}/mise"
export MISE_DATA_DIR="${XDG_DATA_HOME}/mise"
export MISE_CACHE_DIR="${XDG_CACHE_HOME}/mise"

# -- Atuin (shell history)
export ATUIN_CONFIG_DIR="${XDG_CONFIG_HOME}/atuin"

# -- ripgrep
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"

# -- bat
export BAT_CONFIG_PATH="${XDG_CONFIG_HOME}/bat/config"

# -- fd
export FD_CONFIG_PATH="${XDG_CONFIG_HOME}/fd"

# -- Starship
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship.toml"
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# -- Navi
export NAVI_CONFIG="${XDG_CONFIG_HOME}/navi/config.yaml"

# -- Most pager
export MOST_INITFILE="${XDG_CONFIG_HOME}/most/mostrc"

# -- Chezmoi
export CHEZMOI_SOURCE_PATH="${XDG_DATA_HOME}/chezmoi"

# -- yazi
export YAZI_CONFIG_HOME="${XDG_CONFIG_HOME}/yazi"

# ============================================================================
# Directory Creation — Ensure all XDG directories exist
# ============================================================================

# @description Create all required XDG directories if they don't exist
function _ensure_xdg_dirs() {
  local dirs=(
    "$XDG_CONFIG_HOME"
    "$XDG_DATA_HOME"
    "$XDG_CACHE_HOME"
    "$XDG_STATE_HOME"
    "$XDG_BIN_HOME"
    "$ZSH_DATA_DIR"
    "$ZSH_CACHE_DIR"
    "$ZSH_STATE_DIR"
    "${XDG_STATE_HOME}/less"
    "${XDG_STATE_HOME}/node"
    "${XDG_STATE_HOME}/python"
    "${XDG_DATA_HOME}/gnupg"
    "${XDG_DATA_HOME}/wget"
  )

  local dir
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || mkdir -p "$dir" 2>/dev/null
  done
}

_ensure_xdg_dirs

log_debug "XDG Base Directories configured"
