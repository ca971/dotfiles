#!/usr/bin/env zsh
# ============================================================================
# @file        tools/fd.zsh
# @description Fd (find replacement) — auto-setup + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_FD_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_FD_LOADED=1

local _fd_cmd="fd"
if ! has "fd" && has "fdfind"; then
  _fd_cmd="fdfind"
  alias fd="fdfind"
elif ! has "fd"; then
  return 0
fi

log_debug "Configuring fd"

[[ -f "${DOTFILES_DIR}/config/tools.d/fd.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/fd.zsh"

# ── Native config ───────────────────────────────────────────────────────────
function _fd_generate_config() {
  local ignore_file="${XDG_CONFIG_HOME:-${HOME}/.config}/fd/ignore"
  [[ -s "$ignore_file" ]] && return 0
  mkdir -p "$(dirname "$ignore_file")" 2>/dev/null
  cat > "$ignore_file" << 'EOF'
.git
node_modules
__pycache__
*.pyc
.cache
target
dist
build
.next
vendor
.venv
*.zwc
.DS_Store
EOF
}
_fd_generate_config

# ── Functions ────────────────────────────────────────────────────────────────
function ff()      { command ${_fd_cmd} --type f --hidden --follow --exclude .git "$@"; }
function fdir()    { command ${_fd_cmd} --type d --hidden --follow --exclude .git "$@"; }
function fext()    { local ext="$1"; shift; command ${_fd_cmd} --type f --extension "$ext" --hidden --follow "$@"; }
function fbig()    { local size="${1:-10M}"; local dir="${2:-.}"; command ${_fd_cmd} --type f --size "+${size}" "$dir" --exec ls -lh {} \; | sort -k5 -h -r; }
function frecent() { local days="${1:-1}"; command ${_fd_cmd} --type f --changed-within "${days}d" --hidden --follow --exclude .git "${2:-.}"; }
function fempty()  { command ${_fd_cmd} --type empty --hidden "${1:-.}"; }
function fd-regen() { rm -f "${XDG_CONFIG_HOME:-${HOME}/.config}/fd/ignore"; _fd_generate_config; log_info "fd config regenerated"; }

log_debug "fd configured"
