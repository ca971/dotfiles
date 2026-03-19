#!/usr/bin/env zsh
[[ -n "${_ZSH_TOOLS_JUST_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_JUST_LOADED=1
has "just" || return 0
log_debug "Configuring just"

[[ -f "${DOTFILES_DIR}/config/tools.d/just.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/just.zsh"

function ji() { has "fzf" || { just --list; return; }; local r; r=$(just --list --unsorted 2>/dev/null | tail -n +2 | fzf --header='Just recipe' --preview='just --show {1} 2>/dev/null' | awk '{print $1}'); [[ -n "$r" ]] && just "$r"; }
function just-init() { [[ -f "Justfile" || -f "justfile" ]] && { log_warn "Justfile exists"; return 1; }; cat > Justfile << 'EOF'
default:
  @just --list --unsorted

build:
  @echo "Building..."

test:
  @echo "Testing..."

clean:
  @echo "Cleaning..."
EOF
  log_info "Justfile created"; }

log_debug "just configured"
