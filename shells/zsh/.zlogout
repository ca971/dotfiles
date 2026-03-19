#!/usr/bin/env zsh
# ============================================================================
# @file        .zlogout
# @description Cleanup hook executed when a login shell exits.
#              Performs cleanup tasks such as clearing sensitive data
#              and temporary files.
#
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @note        This file runs only when a LOGIN shell exits.
# ============================================================================

# ============================================================================
# Cleanup Tasks
# ============================================================================

# @description Clear terminal scrollback buffer for security
# Prevents sensitive command history from being visible after logout
if [[ -o interactive ]]; then
  # -- Clear screen (works across most terminals)
  clear 2>/dev/null

  # -- Clear scrollback (terminal-specific escape sequences)
  printf '\033[3J' 2>/dev/null  # xterm/VTE
  printf '\033c' 2>/dev/null    # Reset terminal

  # -- Clear any sensitive environment variables
  unset AWS_SECRET_ACCESS_KEY 2>/dev/null
  unset AWS_SESSION_TOKEN 2>/dev/null
  unset GITHUB_TOKEN 2>/dev/null
fi

# @description Remove stale temporary files created during session
local _zsh_tmpdir="${TMPDIR:-/tmp}/zsh-${USER}"
if [[ -d "$_zsh_tmpdir" ]]; then
  rm -rf "$_zsh_tmpdir" 2>/dev/null
fi
unset _zsh_tmpdir
