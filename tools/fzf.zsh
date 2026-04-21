#!/usr/bin/env zsh
# ============================================================================
# @file        tools/fzf.zsh
# @description FZF — shell integration + fonctions.
# @version     5.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_FZF_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_FZF_LOADED=1

has "fzf" || return 0
log_debug "Configuring fzf"

# ── Shell integration ────────────────────────────────────────────────────────
# NOTE: Do NOT use --no-ctrl-r because this flag does not exist in the
# Homebrew version of fzf. The safety net below handles the conflict with Atuin.

local _fzf_loaded=0

if (( ! _fzf_loaded )); then
    eval "$(fzf --zsh 2>/dev/null)" && _fzf_loaded=1
fi

if (( ! _fzf_loaded )) && [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
    local _fzf_brew="${HOMEBREW_PREFIX}/opt/fzf/shell"
    if [[ -d "$_fzf_brew" ]]; then
        [[ -f "${_fzf_brew}/completion.zsh" ]]    && source "${_fzf_brew}/completion.zsh"
        [[ -f "${_fzf_brew}/key-bindings.zsh" ]]  && source "${_fzf_brew}/key-bindings.zsh"
        _fzf_loaded=1
    fi
fi

if (( ! _fzf_loaded )); then
    for _fzf_sys in /usr/share/fzf /usr/share/doc/fzf/examples /usr/share/fzf/shell; do
        if [[ -d "$_fzf_sys" ]]; then
            [[ -f "${_fzf_sys}/completion.zsh" ]]   && source "${_fzf_sys}/completion.zsh"
            [[ -f "${_fzf_sys}/key-bindings.zsh" ]] && source "${_fzf_sys}/key-bindings.zsh"
            _fzf_loaded=1
            break
        fi
    done
fi
unset _fzf_loaded _fzf_sys

# ── Safety net: Atuin takes over Ctrl+R if its widget exists ───────────────────
# fzf --zsh binds Ctrl+R to fzf-history-widget.
# If Atuin is loaded (tools/atuin.zsh is sourced BEFORE fzf.zsh in
# the alphabetical loop), its widget already exists and control is handed back to it.

if (( ${+widgets[atuin-search]} )); then
    bindkey '^r' atuin-search
fi

# ── Functions ────────────────────────────────────────────────────────────────
function fkill() {
    local pid
    if (( EUID == 0 )); then
        pid=$(ps -ef | sed 1d | fzf -m --header='Kill process' | awk '{print $2}')
    else
        pid=$(ps -f -u "$USER" | sed 1d | fzf -m --header='Kill process' | awk '{print $2}')
    fi
    [[ -n "$pid" ]] && echo "$pid" | xargs kill -"${1:-9}"
}

function fenv() {
    env | sort | fzf --preview='echo {}' --preview-window='up:1:wrap' --header='Env vars'
}

function fe() {
    local file
    file=$(fd --type f --hidden --follow --exclude .git "${1:-.}" | \
        fzf --preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null' \
            --header='Edit file')
    [[ -n "$file" ]] && "${EDITOR:-nvim}" "$file"
}

function frg() {
    local prefix="rg --column --line-number --no-heading --color=always --smart-case"
    fzf --ansi --disabled --query "${1:-}" \
        --bind "start:reload:$prefix {q} || true" \
        --bind "change:reload:sleep 0.1; $prefix {q} || true" \
        --delimiter ':' \
        --preview 'bat --color=always --highlight-line {2} {1} 2>/dev/null' \
        --preview-window 'right:60%:+{2}-5' \
        --header='Live Grep' \
        --bind "enter:become(${EDITOR:-nvim} {1} +{2})"
}

function fbranch() {
    local branch
    branch=$(git branch --all --sort=-committerdate | grep -v 'HEAD' | \
        fzf --preview 'git log --oneline --graph --color=always --max-count=20 {1}' \
            --header='Git branch' | \
        sed 's/^[* ]*//' | sed 's|remotes/origin/||')
    [[ -n "$branch" ]] && git checkout "$branch"
}

function flog() {
    git log --oneline --graph --color=always --all | \
        fzf --ansi --no-sort \
            --preview 'git show --color=always {1}' \
            --preview-window 'right:60%:wrap' \
            --header='Git Log' \
            --bind 'enter:execute(git show --color=always {1} | less -R)'
}

log_debug "fzf configured"
