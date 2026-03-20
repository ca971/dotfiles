#!/usr/bin/env zsh
# ============================================================================
# @file        tools/tldr.zsh
# @description TLDR pages — simplified man pages.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_TLDR_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_TLDR_LOADED=1

has "tldr" || return 0
log_debug "Configuring tldr"


function tldr-browse() { has "fzf" && tldr --list 2>/dev/null | fzf --header='TLDR' --preview='tldr {1} --color=always 2>/dev/null' --preview-window='right:60%:wrap' | xargs -r tldr || tldr --list; }
function tldr-search() { local kw="${1:?Usage: tldr-search <keyword>}"; has "fzf" && tldr --list 2>/dev/null | grep -i "$kw" | fzf --preview='tldr {1}' | xargs -r tldr || tldr --list | grep -i "$kw"; }
function tldr-random() { local all=$(tldr --list 2>/dev/null); local n=$(echo "$all" | wc -l | tr -d ' '); local r=$(( RANDOM % n + 1 )); local cmd=$(echo "$all" | sed -n "${r}p"); printf "\n  🎲 %s\n\n" "$cmd"; tldr "$cmd"; }

log_debug "tldr configured"
