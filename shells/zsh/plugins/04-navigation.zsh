#!/usr/bin/env zsh
# ============================================================================
# @file        plugins/04-navigation.zsh
# @description Navigation enhancement plugins.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.2.0
#
# @depends     plugins/00-zinit-bootstrap.zsh, lib/tool-check.zsh
# @changelog   1.2.0 — Removed tymm/zsh-directory-history (requires external
#              dirhist binary not commonly available). Replaced with
#              native ZSH directory stack usage.
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_PLUGINS_NAVIGATION_LOADED:-}" ]] && return 0
readonly _ZSH_PLUGINS_NAVIGATION_LOADED=1

log_debug "Loading navigation plugins"

# ============================================================================
# FZF Tab — Replace zsh completion menu with FZF
# ============================================================================

if has "fzf"; then
  zinit ice wait"0" lucid
  zinit light Aloxaf/fzf-tab

  # @description  Configure fzf-tab AFTER loading via a precmd hook
  function _configure_fzf_tab() {
    add-zsh-hook -d precmd _configure_fzf_tab

    zstyle ':fzf-tab:*' fzf-command fzf
    zstyle ':fzf-tab:*' continuous-trigger '/'
    zstyle ':fzf-tab:*' switch-group '<' '>'
    zstyle ':fzf-tab:*' fzf-min-height 15

    zstyle ':fzf-tab:complete:*:*' fzf-preview \
      'if [[ -f $realpath ]]; then
        bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || cat $realpath
      elif [[ -d $realpath ]]; then
        eza --icons --tree --level=1 --color=always $realpath 2>/dev/null || ls -la $realpath
      fi'

    zstyle ':fzf-tab:complete:*:*' fzf-flags \
      '--preview-window=right:50%:wrap' \
      '--height=70%' \
      '--border' \
      '--info=inline'

    zstyle ':fzf-tab:complete:cd:*' fzf-preview \
      'eza --icons --tree --level=1 --color=always $realpath 2>/dev/null || ls -la $realpath'

    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
      'ps -p $word -o pid,user,%cpu,%mem,stat,start,time,command 2>/dev/null || echo "Process not found"'
    zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:5:wrap'

    zstyle ':fzf-tab:complete:(-parameter-|export|unset|typeset):*' fzf-preview \
      'echo ${(P)word}'

    zstyle ':fzf-tab:complete:git-(add|diff|restore|checkout):*' fzf-preview \
      'git diff --color=always $word 2>/dev/null || echo "No diff"'
    zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
      'git log --oneline --graph --color=always --max-count=20 $word 2>/dev/null'

    zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
      'SYSTEMD_COLORS=1 systemctl status -- $word 2>/dev/null'

    log_debug "fzf-tab configured with context previews"
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _configure_fzf_tab
fi

# ============================================================================
# Marks — Directory bookmarks
# ============================================================================

zinit ice wait"1" lucid
zinit snippet OMZP::jump

# ============================================================================
# Z — Quick directory jumping (fallback if zoxide not available)
# ============================================================================

if ! has "zoxide"; then
  log_debug "zoxide not found — loading z plugin as fallback"
  zinit ice wait"1" lucid
  zinit light agkozak/zsh-z
fi

# ============================================================================
# Forgit — Interactive Git with FZF
# ============================================================================

if has "fzf"; then
  zinit ice wait"1" lucid atload"
    FORGIT_ADD_FZF_OPTS='--reverse --height=80%'
    FORGIT_LOG_FZF_OPTS='--reverse --height=80%'
    FORGIT_DIFF_FZF_OPTS='--reverse --height=80%'

    if command -v delta &>/dev/null; then
      FORGIT_DIFF_PAGER='delta --side-by-side'
      FORGIT_SHOW_PAGER='delta'
      FORGIT_LOG_SHOW_PAGER='delta'
    fi
  "
  zinit light wfxr/forgit
fi

log_debug "Navigation plugins loaded"
