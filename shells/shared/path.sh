#!/bin/sh
# ============================================================================
# @file        shells/shared/path.sh
# @description Single Source of Truth for PATH construction.
#              POSIX sh — sourced by zsh and bash.
# @version     1.0.0
# ============================================================================

_add_path() {
    case ":${PATH}:" in
        *:"$1":*) ;;
        *) [ -d "$1" ] && export PATH="$1:${PATH}" ;;
    esac
}

# ── Dev workspace ────────────────────────────────────────────────────────────
_add_path "${DEV_HOME}/tools/bin"

# ── User local ───────────────────────────────────────────────────────────────
_add_path "${HOME}/.local/bin"
_add_path "${DOTFILES_DIR:-${HOME}/dotfiles}/bin"
_add_path "${DOTFILES_DIR:-${HOME}/dotfiles}/config/git/bin"
_add_path "${HOME}/bin"

# ── Homebrew ─────────────────────────────────────────────────────────────────
if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ── Language runtimes ────────────────────────────────────────────────────────
_add_path "${XDG_DATA_HOME:-${HOME}/.local/share}/cargo/bin"
_add_path "${XDG_DATA_HOME:-${HOME}/.local/share}/go/bin"
_add_path "${XDG_DATA_HOME:-${HOME}/.local/share}/gem/bin"
_add_path "$(ruby -e 'print Gem.user_dir')/bin"

# Afficher le PATH ligne par ligne
show_path() {
    echo "$PATH" | tr ':' '\n' | nl
}

unset -f _add_path
