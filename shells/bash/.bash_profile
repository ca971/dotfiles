#!/usr/bin/env bash
# ============================================================================
# @file        shells/bash/.bash_profile
# @description Bash login shell profile. Sourced once during login.
#              Sets up DOTFILES_DIR and sources .bashrc for interactive use.
#
#              Symlink: ln -sf ~/dotfiles/shells/bash/.bash_profile ~/.bash_profile
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-15
# @version     1.0.0
# ============================================================================

# ============================================================================
# DOTFILES_DIR — Root of the dotfiles repository
# ============================================================================

# @description  Resolve dotfiles root from this file's real location
if [[ -z "${DOTFILES_DIR:-}" ]]; then
    _this_file="${BASH_SOURCE[0]}"
    if [[ -L "$_this_file" ]]; then
        _this_file="$(readlink -f "$_this_file" 2> /dev/null || readlink "$_this_file")"
    fi
    _bash_dir="$(cd "$(dirname "$_this_file")" && pwd)"
    _shells_dir="$(cd "${_bash_dir}/.." && pwd)"
    export DOTFILES_DIR="$(cd "${_shells_dir}/.." && pwd)"
    unset _this_file _bash_dir _shells_dir
fi

# ============================================================================
# XDG Base Directories
# ============================================================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"

# ============================================================================
# PATH
# ============================================================================

_add_to_path() {
    case ":${PATH}:" in
        *:"$1":*) ;;
        *) export PATH="$1:${PATH}" ;;
    esac
}

_add_to_path "${XDG_BIN_HOME}"
_add_to_path "${HOME}/bin"

# -- Homebrew (macOS)
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# -- Cargo, Go, etc.
[[ -d "${HOME}/.local/share/cargo/bin" ]] && _add_to_path "${HOME}/.local/share/cargo/bin"
[[ -d "${HOME}/.local/share/go/bin" ]] && _add_to_path "${HOME}/.local/share/go/bin"

unset -f _add_to_path

# ============================================================================
# Source .bashrc for interactive shells
# ============================================================================

if [[ -f "${DOTFILES_DIR}/shells/bash/.bashrc" ]]; then
    source "${DOTFILES_DIR}/shells/bash/.bashrc"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/ca/.lmstudio/bin"
# End of LM Studio CLI section

