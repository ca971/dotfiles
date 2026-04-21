#!/usr/bin/env zsh
# ============================================================================
# @file        plugins/05-extras.zsh
# @description Nice-to-have plugins that enhance the shell experience without
#              being critical to core functionality.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @depends     plugins/00-zinit-bootstrap.zsh
# @changelog   1.1.0 — Removed zsh-directory-history (missing dirhist binary).
#              Removed OMZP::nix (404 — snippet removed from OMZ).
#              Fixed zsh-notify to require terminal-notifier on macOS.
#              Fixed per-directory-history loading.
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_PLUGINS_EXTRAS_LOADED:-}" ]] && return 0
readonly _ZSH_PLUGINS_EXTRAS_LOADED=1

log_debug "Loading extra plugins"

# ============================================================================
# Notification — Command completion alerts
# ============================================================================

# @description  zsh-notify sends desktop notifications when long-running
#               commands finish. Requires:
#               - macOS: terminal-notifier (brew install terminal-notifier)
#               - Linux: libnotify / notify-send
#               Only loaded in supported environments.
if [[ "$ZSH_IS_SSH" -eq 0 ]] && [[ "$ZSH_IS_CONTAINER" -eq 0 ]]; then
  local _notify_supported=0

  if [[ "$ZSH_PLATFORM" == "darwin" ]] && has "terminal-notifier"; then
    _notify_supported=1
  elif [[ "$ZSH_PLATFORM" == "linux" ]] && has "notify-send"; then
    _notify_supported=1
  fi

  if (( _notify_supported )); then
    zinit ice wait"2" lucid atload"
      zstyle ':notify:*' command-complete-timeout 30
      zstyle ':notify:*' success-title 'Command finished'
      zstyle ':notify:*' error-title 'Command failed'
    "
    zinit light marzocchi/zsh-notify
  fi
  unset _notify_supported
fi

# ============================================================================
# Colored Man Pages (enhanced)
# ============================================================================

zinit ice wait"2" lucid atload"
  export LESS_TERMCAP_mb=\$'\\e[1;31m'
  export LESS_TERMCAP_md=\$'\\e[1;36m'
  export LESS_TERMCAP_me=\$'\\e[0m'
  export LESS_TERMCAP_so=\$'\\e[01;33m'
  export LESS_TERMCAP_se=\$'\\e[0m'
  export LESS_TERMCAP_us=\$'\\e[1;32m'
  export LESS_TERMCAP_ue=\$'\\e[0m'
"
zinit light zdharma-continuum/null

# ============================================================================
# Diff So Fancy (fallback if delta unavailable)
# ============================================================================

if ! has "delta"; then
  zinit ice wait"2" lucid as"program" pick"bin/git-dsf"
  zinit light zdharma-continuum/zsh-diff-so-fancy
fi

# ============================================================================
# SSH Agent (silent)
# ============================================================================

zinit ice wait"2" lucid atload"
  zstyle ':omz:plugins:ssh-agent' quiet yes
  zstyle ':omz:plugins:ssh-agent' lazy yes
"
zinit snippet OMZP::ssh-agent

# ============================================================================
# Command Not Found — Package suggestion when command is missing
# ============================================================================

case "$ZSH_PLATFORM" in
  darwin)
    if has "brew"; then
      zinit ice wait"2" lucid
      # zinit snippet OMZP::brew
    fi
    ;;
  linux|wsl)
    case "$ZSH_DISTRO" in
      ubuntu|debian)
        if [[ -f "/etc/zsh_command_not_found" ]]; then
          zinit ice wait"2" lucid
          zinit snippet OMZP::command-not-found
        fi
        ;;
      arch|manjaro|endeavouros)
        if has "pkgfile"; then
          zinit ice wait"2" lucid
          zinit snippet OMZP::command-not-found
        fi
        ;;
    esac
    ;;
esac

# ============================================================================
# Git Flow (if installed)
# ============================================================================

if has "git-flow" || git flow version &>/dev/null 2>&1; then
  zinit ice wait"2" lucid
  zinit snippet OMZP::git-flow
fi

# ============================================================================
# Per-Directory History Toggle
# ============================================================================

# @description  Toggle between global history and per-directory history
#               with Ctrl-G. Uses the OMZ plugin directly with explicit
#               script sourcing to avoid loading issues.
# zinit ice wait"2" lucid
# zinit snippet OMZP::per-directory-history/per-directory-history.zsh

# ============================================================================
# ZSH Vi Mode (optional — controlled by SSOT feature flag)
# ============================================================================

if [[ "${ZSH_VI_MODE:-0}" -eq 1 ]]; then
  zinit ice depth=1 wait"1" lucid atload"
    export KEYTIMEOUT=1
    VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
    VI_MODE_SET_CURSOR=true
  "
  zinit light jeffreytse/zsh-vi-mode
fi

# ============================================================================
# Emoji CLI (fun, low priority)
# ============================================================================

if [[ "$ZSH_IS_SSH" -eq 0 ]] && [[ "$ZSH_IS_CONTAINER" -eq 0 ]]; then
  if has "fzf"; then
    zinit ice wait"3" lucid
    zinit light b4b4r07/emoji-cli 2>/dev/null || true
  fi
fi

log_debug "Extra plugins loaded"
