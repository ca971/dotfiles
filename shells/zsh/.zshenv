#!/usr/bin/env zsh
# ============================================================================
# @file        shells/zsh/.zshenv
# @description ZSH environment entry point. This is the FIRST file sourced
#              by every ZSH instance (login, interactive, script, subshell).
#
#              Sets DOTFILES_DIR to the root of the dotfiles repository,
#              and ZDOTDIR to the ZSH-specific directory within it.
#
#              Symlink: ln -sf ~/dotfiles/shells/zsh/.zshenv ~/.zshenv
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     2.0.0
#
# @changelog   2.0.0 — Restructured for cross-platform cross-shell dotfiles.
#              Added DOTFILES_DIR as the primary root reference.
#              ZDOTDIR now points to shells/zsh/ subdirectory.
#              All shared resources accessed via DOTFILES_DIR.
#
# @note        Keep this file MINIMAL. It runs for every ZSH process
#              (login, interactive, scripts, subshells).
#              Heavy initialization belongs in .zshrc (interactive only).
# ============================================================================

# ============================================================================
# DOTFILES_DIR — Root of the dotfiles repository
# ============================================================================

# @description  Resolve the dotfiles root directory.
#               Detection strategy:
#               1. Use DOTFILES_DIR if already set (env override)
#               2. Resolve from this file's real path (works with symlinks)
#               3. Fall back to ~/dotfiles
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  # -- This file is at: dotfiles/shells/zsh/.zshenv
  # -- So dotfiles root is: ../../ from this file's real location
  local _this_file="${(%):-%x}"
  if [[ -L "$_this_file" ]]; then
    # -- Resolve symlink to find the real file location
    if command -v realpath &>/dev/null; then
      _this_file="$(realpath "$_this_file")"
    elif command -v readlink &>/dev/null; then
      _this_file="$(readlink -f "$_this_file" 2>/dev/null || readlink "$_this_file")"
    fi
  fi

  local _zsh_dir="${_this_file:h}"     # Directory containing .zshenv
  local _shells_dir="${_zsh_dir:h}"    # shells/ directory
  export DOTFILES_DIR="${_shells_dir:h}" # dotfiles/ root

  unset _this_file _zsh_dir _shells_dir
fi

# @description  Validate DOTFILES_DIR points to a real directory
if [[ ! -d "$DOTFILES_DIR" ]]; then
  # -- Fallback to common locations
  if [[ -d "${HOME}/dotfiles" ]]; then
    export DOTFILES_DIR="${HOME}/dotfiles"
  elif [[ -d "${HOME}/.dotfiles" ]]; then
    export DOTFILES_DIR="${HOME}/.dotfiles"
  elif [[ -d "${HOME}/.config/dotfiles" ]]; then
    export DOTFILES_DIR="${HOME}/.config/dotfiles"
  else
    export DOTFILES_DIR="${HOME}/dotfiles"
  fi
fi

# ============================================================================
# ZDOTDIR — ZSH config directory (within dotfiles)
# ============================================================================

# @description  Point ZSH to its shell-specific directory.
#               All ZSH files (.zshrc, .zprofile, etc.) live here.
#               Shared resources are accessed via DOTFILES_DIR.
export ZDOTDIR="${DOTFILES_DIR}/shells/zsh"

# ============================================================================
# XDG Base Directories — Bootstrap (minimal set, expanded in core/00-xdg.zsh)
# ============================================================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"

# ============================================================================
# Dotfiles Metadata
# ============================================================================

# @description  Configuration version for compatibility tracking
export ZSH_CONFIG_VERSION="2.0.0"

# @description  Repository URL for self-update mechanism
export ZSH_CONFIG_REPO="https://github.com/ca971/dotfiles.git"

# ============================================================================
# Startup Profiling (opt-in via ZSH_PROFILE=1)
# ============================================================================

# @description  Enable ZSH startup profiling when ZSH_PROFILE=1
#              Usage: ZSH_PROFILE=1 zsh -ic exit
if [[ "${ZSH_PROFILE:-0}" == "1" ]]; then
  zmodload zsh/zprof
fi

# ============================================================================
# Security — Restrict permissions on sensitive dirs
# ============================================================================

[[ -d "$ZDOTDIR" ]] || mkdir -p "$ZDOTDIR" 2>/dev/null
umask 022

# @description  Default log level — INFO for normal use, DEBUG for troubleshooting
#               Set ZSH_LOG_LEVEL=0 for debug output
export ZSH_LOG_LEVEL="${ZSH_LOG_LEVEL:-1}"  # 1 = INFO (skip DEBUG)
