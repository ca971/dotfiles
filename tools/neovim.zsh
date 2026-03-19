#!/usr/bin/env zsh
# ============================================================================
# @file        tools/neovim.zsh
# @description Neovim integration and configuration. Sets up Neovim as the
#              default editor, configures environment variables, provides
#              session management functions, and integrates with terminal
#              multiplexers.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @see         https://neovim.io
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

[[ -n "${_ZSH_TOOLS_NEOVIM_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_NEOVIM_LOADED=1

has "nvim" || return 0

log_debug "Configuring neovim"

# ============================================================================
# Constants
# ============================================================================

readonly NVIM_CONFIG_REPO="https://github.com/ca971/nvim-enterprise.git"
readonly NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"

# ============================================================================
# Auto-Setup — Clone config if missing, update in background
# ============================================================================

function _neovim_auto_setup() {
  if [[ ! -d "${NVIM_CONFIG_DIR}/.git" ]]; then
    if [[ -d "$NVIM_CONFIG_DIR" ]] && [[ -n "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]]; then
      # Directory exists but not a git repo — backup and clone
      mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.bak.$(date +%s)" >/dev/null 2>&1
    fi
    log_info "Cloning nvim-enterprise..."
    git clone --depth=1 "$NVIM_CONFIG_REPO" "$NVIM_CONFIG_DIR" >/dev/null 2>&1 && \
      log_info "nvim-enterprise installed" || \
      log_warn "nvim-enterprise clone failed (check network)"
  else
    # Update in background
    { git -C "$NVIM_CONFIG_DIR" pull --rebase --quiet 2>/dev/null } &!
  fi
}

_neovim_auto_setup

# ============================================================================
# Environment Variables
# ============================================================================

export EDITOR="nvim"
export VISUAL="nvim"
export SUDO_EDITOR="nvim"
export GIT_EDITOR="nvim"
export KUBE_EDITOR="nvim"

# ============================================================================
# Aliases
# ============================================================================

alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias vd="nvim -d"
alias vr="nvim -R"
alias vn="nvim --clean"

# ============================================================================
# Functions
# ============================================================================

# @description  Open file at line:col from grep/ripgrep output
# @param  $1    string  file:line:col format
# @return       void
function v@() {
  local input="$1"
  [[ -z "$input" ]] && { nvim; return; }

  if [[ "$input" =~ ^(.+):([0-9]+):([0-9]+)$ ]]; then
    nvim "+call cursor(${match[2]},${match[3]})" "${match[1]}"
  elif [[ "$input" =~ ^(.+):([0-9]+)$ ]]; then
    nvim "+${match[2]}" "${match[1]}"
  else
    nvim "$input"
  fi
}

# @description  Open file via FZF selection
# @param  $1    string  (optional) Directory
# @return       void
function vf() {
  has "fzf" || { nvim "$@"; return; }
  local file
  file=$(fd --type f --hidden --follow --exclude .git "${1:-.}" 2>/dev/null | \
    fzf --preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null' \
        --header='Select file')
  [[ -n "$file" ]] && nvim "$file"
}

# @description  Search + open via ripgrep + FZF
# @param  $1    string  Search pattern
# @return       void
function vg() {
  has "fzf" && has "rg" || { log_warn "fzf + rg required"; return 1; }
  local pattern="${1:-}"
  [[ -z "$pattern" ]] && { printf "Pattern: "; read -r pattern; }
  local result
  result=$(rg --column --line-number --no-heading --color=always "$pattern" 2>/dev/null | \
    fzf --ansi --delimiter ':' \
        --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' \
        --header="Search: ${pattern}")
  if [[ -n "$result" ]]; then
    local file=$(echo "$result" | cut -d: -f1)
    local line=$(echo "$result" | cut -d: -f2)
    nvim "+${line}" "$file"
  fi
}

# @description  Neovim health check
function vhealth() { nvim "+checkhealth" "+only"; }

# @description  Show nvim-enterprise config info
function nvim-info() {
  printf "\n  ✏️  Neovim Config\n"
  printf "  ─────────────────────────────────\n"
  printf "  Repo:    %s\n" "$NVIM_CONFIG_REPO"
  printf "  Local:   %s\n" "$NVIM_CONFIG_DIR"
  if [[ -d "${NVIM_CONFIG_DIR}/.git" ]]; then
    printf "  Status:  ✅ installed\n"
    printf "  Commit:  %s\n" "$(git -C "$NVIM_CONFIG_DIR" rev-parse --short HEAD 2>/dev/null)"
    printf "  Updated: %s\n" "$(git -C "$NVIM_CONFIG_DIR" log -1 --format='%ar' 2>/dev/null)"
  else
    printf "  Status:  ❌ not installed\n"
  fi
  printf "  Version: %s\n" "$(nvim --version 2>/dev/null | head -1)"
  printf "  ─────────────────────────────────\n\n"
}

# @description  Update nvim-enterprise config
function nvim-update() {
  if [[ -d "${NVIM_CONFIG_DIR}/.git" ]]; then
    log_info "Updating nvim-enterprise..."
    git -C "$NVIM_CONFIG_DIR" pull --rebase
    log_info "Updated"
  else
    log_warn "Not a git repo — reinstalling..."
    _neovim_auto_setup
  fi
}

# @description  Reinstall nvim-enterprise from scratch
function nvim-reinstall() {
  printf "  ⚠️  This will remove %s and reclone. Continue? [y/N]: " "$NVIM_CONFIG_DIR"
  read -rk1 confirm; echo
  if [[ "${confirm:l}" == "y" ]]; then
    rm -rf "$NVIM_CONFIG_DIR"
    _neovim_auto_setup
  fi
}

log_debug "neovim configured"
