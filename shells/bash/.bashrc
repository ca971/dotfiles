#!/usr/bin/env bash
# ============================================================================
# @file        shells/bash/.bashrc
# @description Bash configuration — sources shared resources + Bash-specific.
#              Only contains what is UNIQUE to Bash.
# @version     3.0.0
# ============================================================================

[[ $- != *i* ]] && return

export DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

# ── Shared environment + PATH ────────────────────────────────────────────────
[[ -f "${DOTFILES_DIR}/shells/shared/env.sh" ]] && source "${DOTFILES_DIR}/shells/shared/env.sh"
[[ -f "${DOTFILES_DIR}/shells/shared/path.sh" ]] && source "${DOTFILES_DIR}/shells/shared/path.sh"

# ── Bash-specific options ────────────────────────────────────────────────────
shopt -s histappend cmdhist checkwinsize expand_aliases globstar dotglob
shopt -s nocaseglob cdspell dirspell autocd direxpand 2> /dev/null
stty -ixon 2> /dev/null

# ── Bash-specific history ────────────────────────────────────────────────────
export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/bash/history"
export HISTSIZE=100000 HISTFILESIZE=100000
export HISTCONTROL=ignoreboth:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
mkdir -p "$(dirname "$HISTFILE")" 2> /dev/null

# ── Starship theme ───────────────────────────────────────────────────────────
[[ -f "${DOTFILES_DIR}/themes/starship-selector.sh" ]] \
    && source "${DOTFILES_DIR}/themes/starship-selector.sh"

# ── SSOT Aliases ─────────────────────────────────────────────────────────────
[[ -f "${DOTFILES_DIR}/generated/aliases.bash" ]] \
    && source "${DOTFILES_DIR}/generated/aliases.bash"

# ── Starship (direct init — avoid shellcheck directive issue) ────────────────
if command -v starship &> /dev/null; then
    eval "$(starship init bash 2> /dev/null | sed 's/shellcheck shell=bash//')"
fi

# ── Tool inits (shared dispatcher — WITHOUT starship) ───────────────────────
if [[ -f "${DOTFILES_DIR}/shells/shared/tools-init.sh" ]]; then
    eval "$(SKIP_STARSHIP=1 sh "${DOTFILES_DIR}/shells/shared/tools-init.sh" bash 2> /dev/null)"
fi

# ── Bash completions ────────────────────────────────────────────────────────
[[ -f /etc/bash_completion ]] && source /etc/bash_completion
[[ -f "${HOMEBREW_PREFIX:-/opt/homebrew}/etc/profile.d/bash_completion.sh" ]] \
    && source "${HOMEBREW_PREFIX:-/opt/homebrew}/etc/profile.d/bash_completion.sh"

# ── Thefuck (lazy) ──────────────────────────────────────────────────────────
command -v thefuck &> /dev/null && fuck() {
    unset -f fuck
    eval "$(thefuck --alias)"
    fuck "$@"
}

# ── dot wrapper ──────────────────────────────────────────────────────────────
dot() {
    case "${1:-help}" in
        theme | th)
            shift
            case "${1:-}" in
                powerline | minimal | nerd)
                    export STARSHIP_CONFIG="${DOTFILES_DIR}/themes/starship-${1}.toml" STARSHIP_THEME="$1"
                    echo "  ✓ Theme: $1"
                    ;;
                *) command dot theme "$@" ;; esac
            ;;
        cd) cd "${DOTFILES_DIR}" ;;
        *) command dot "$@" ;;
    esac
}

# ── Local ────────────────────────────────────────────────────────────────────
[[ -f "${DOTFILES_DIR}/local/local.bash" ]] && source "${DOTFILES_DIR}/local/local.bash"
[[ -f "${DOTFILES_DIR}/local/local.sh" ]] && source "${DOTFILES_DIR}/local/local.sh"

# ── Fastfetch ────────────────────────────────────────────────────────────────
command -v fastfetch &> /dev/null && [[ -z "${BASH_NO_FASTFETCH:-}" ]] && fastfetch
