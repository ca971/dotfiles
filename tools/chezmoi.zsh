#!/usr/bin/env zsh
# ============================================================================
# @file        tools/chezmoi.zsh
# @description Chezmoi (dotfile manager).
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_CHEZMOI_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_CHEZMOI_LOADED=1

has "chezmoi" || return 0
log_debug "Configuring chezmoi"


function cm-edit()   { has "fzf" && chezmoi managed --include=files | fzf --preview 'chezmoi diff -- {} 2>/dev/null || bat --color=always {} 2>/dev/null' --header='Managed files' | xargs -r chezmoi edit || chezmoi managed; }
function cm-push()   { local m="${1:-chore: update dotfiles}"; chezmoi git -- add -A; chezmoi git -- commit -m "$m"; chezmoi git -- push; log_info "Pushed: %s" "$m"; }
function cm-info()   { printf "\n  📦 Chezmoi\n  ─────────────────\n  Source: %s\n  Managed: %s files\n  Changed: %s\n  ─────────────────\n\n" "$(chezmoi source-path)" "$(chezmoi managed --include=files 2>/dev/null | wc -l | tr -d ' ')" "$(chezmoi status 2>/dev/null | wc -l | tr -d ' ')"; }

log_debug "chezmoi configured"
