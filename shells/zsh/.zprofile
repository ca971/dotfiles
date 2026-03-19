#!/usr/bin/env zsh
# ============================================================================
# @file        .zprofile
# @description Login shell profile. Sourced ONCE during login shell
#              initialization (after .zshenv, before .zshrc).
#              Used for setting up environment that should only be
#              configured once per login session.
#
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @note        This file runs only for LOGIN shells.
#              Do NOT put interactive config here (use .zshrc instead).
# ============================================================================

# ============================================================================
# PATH — Login-time additions
# ============================================================================

# @description Ensure user-local bin directories are in PATH for login shells
# Uses zsh unique array to prevent duplicates
typeset -gU path
path=(
  "${XDG_BIN_HOME}"
  "${HOME}/bin"
  $path
)

# ============================================================================
# macOS Homebrew — Evaluate shellenv for login shells
# ============================================================================

if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# ============================================================================
# SSH Agent — Start silently if not running
# ============================================================================

if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
  local _ssh_env="${XDG_STATE_HOME:-${HOME}/.local/state}/ssh/agent-env"
  mkdir -p "$(dirname "$_ssh_env")" 2>/dev/null

  if [[ -f "$_ssh_env" ]]; then
    source "$_ssh_env" >/dev/null 2>&1
    kill -0 "$SSH_AGENT_PID" 2>/dev/null || {
      eval "$(ssh-agent -s)" >/dev/null 2>&1
      echo "export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" > "$_ssh_env"
      echo "export SSH_AGENT_PID=${SSH_AGENT_PID}" >> "$_ssh_env"
    }
  else
    eval "$(ssh-agent -s)" >/dev/null 2>&1
    echo "export SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" > "$_ssh_env"
    echo "export SSH_AGENT_PID=${SSH_AGENT_PID}" >> "$_ssh_env"
  fi
  unset _ssh_env
fi
