#!/bin/sh
# ============================================================================
# @file        shells/shared/env.sh
# @description Single Source of Truth for environment variables.
#              POSIX sh — sourced by zsh and bash directly.
#              Fish and Nushell read these via their own adapters.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @version     1.0.0
# ============================================================================

# shellcheck disable=SC2034

# ── Dotfiles ─────────────────────────────────────────────────────────────────
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"
export DOTFILES_DIR

# ── Local env overrides (loaded FIRST — highest priority) ────────────────────
# This allows local/local.env to override ANY variable before it's set below.
# local.env is gitignored — safe for machine-specific overrides.
if [ -f "${DOTFILES_DIR}/local/local.env" ]; then
    . "${DOTFILES_DIR}/local/local.env"
fi

# ── XDG Base Directories ────────────────────────────────────────────────────
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
export XDG_BIN_HOME="${XDG_BIN_HOME:-${HOME}/.local/bin}"

# ── Editor ───────────────────────────────────────────────────────────────────
if command -v nvim > /dev/null 2>&1; then
    export EDITOR="nvim" VISUAL="nvim" SUDO_EDITOR="nvim"
    export GIT_EDITOR="nvim" KUBE_EDITOR="nvim"
elif command -v vim > /dev/null 2>&1; then
    export EDITOR="vim" VISUAL="vim"
else
    export EDITOR="vi" VISUAL="vi"
fi

# ── Pager ────────────────────────────────────────────────────────────────────
if command -v most > /dev/null 2>&1; then
    export PAGER="most"
elif command -v bat > /dev/null 2>&1; then
    export PAGER="bat --plain"
else
    export PAGER="less"
fi
export LESS="-R -F -X -i -M -S --tabs=2"
export LESSCHARSET="utf-8"

# ── Locale ───────────────────────────────────────────────────────────────────
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# ── Colors ───────────────────────────────────────────────────────────────────
export CLICOLOR=1
export COLORTERM="${COLORTERM:-truecolor}"

# ── Bat ──────────────────────────────────────────────────────────────────────
export BAT_THEME="${BAT_THEME:-Catppuccin Mocha}"
export BAT_STYLE="${BAT_STYLE:-auto}"

# ── FZF ──────────────────────────────────────────────────────────────────────
if command -v fd > /dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="fd --type f --type d --hidden --follow --exclude .git"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
fi
export FZF_DEFAULT_OPTS="--height=70% --layout=reverse --border --info=inline-right"

# ── Docker ───────────────────────────────────────────────────────────────────
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_CONFIG="${XDG_CONFIG_HOME}/docker"

# ── GPG ──────────────────────────────────────────────────────────────────────
export GNUPGHOME="${XDG_DATA_HOME}/gnupg"

# ── Ripgrep ──────────────────────────────────────────────────────────────────
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/config"

# ── Ruby ─────────────────────────────────────────────────────────────────────
RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
export RUBY_CONFIGURE_OPTS

# ── Gem ──────────────────────────────────────────────────────────────────────
if command -v gem > /dev/null 2>&1; then
    export GEM_HOME="$HOME/.gem"
    export PATH="$GEM_HOME/bin:$PATH"
fi

# ── Bat MANPAGER ─────────────────────────────────────────────────────────────
if command -v bat > /dev/null 2>&1; then
    # shellcheck disable=SC2089
    export MANPAGER="sh -c 'col -bx | bat --language=man --plain'"
    export MANROFFOPT="-c"
elif command -v batcat > /dev/null 2>&1; then
    # shellcheck disable=SC2089
    export MANPAGER="sh -c 'col -bx | batcat --language=man --plain'"
    export MANROFFOPT="-c"
fi

# ── Mise ─────────────────────────────────────────────────────────────────────
export MISE_CONFIG_DIR="${XDG_CONFIG_HOME}/mise"
export MISE_DATA_DIR="${XDG_DATA_HOME}/mise"
export MISE_CACHE_DIR="${XDG_CACHE_HOME}/mise"
export MISE_ASDF_COMPAT=1

# ── Atuin ────────────────────────────────────────────────────────────────────
export ATUIN_CONFIG_DIR="${XDG_CONFIG_HOME}/atuin"
export ATUIN_SUPPRESS_UPDATE_CHECK=1

# ── Starship ─────────────────────────────────────────────────────────────────
export STARSHIP_LOG="error"
export STARSHIP_CACHE="${XDG_CACHE_HOME}/starship"

# ── GitHub CLI ───────────────────────────────────────────────────────────────
export GH_NO_UPDATE_NOTIFIER=1

# ── Homebrew ─────────────────────────────────────────────────────────────────
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_AUTOREMOVE=1

# ── Dev workspace ────────────────────────────────────────────────────────────
export DEV_HOME="$HOME/dev"

# ── Claude Code with Ollama Cloud Models ─────────────────────────────────────
# claude --model kimi-k2.6:cloud
# export ANTHROPIC_BASE_URL=http://localhost:11434
# export ANTHROPIC_AUTH_TOKEN=ollama
# export ANTHROPIC_API_KEY=""
