#!/usr/bin/env zsh
# ============================================================================
# @file        tools/bat.zsh
# @description Bat (cat replacement) — auto-setup + functions.
#              Aliases and options in config/tools.d/bat.zsh
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_BAT_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_BAT_LOADED=1

# Handle Debian/Ubuntu rename
local _bat_cmd="bat"
if ! has "bat" && has "batcat"; then
  _bat_cmd="batcat"
  alias bat="batcat"
elif ! has "bat"; then
  return 0
fi

log_debug "Configuring bat"

# ── Source config ────────────────────────────────────────────────────────────
[[ -f "${DOTFILES_DIR}/config/tools.d/bat.zsh" ]] && source "${DOTFILES_DIR}/config/tools.d/bat.zsh"

# ── MANPAGER integration ────────────────────────────────────────────────────
export MANPAGER="sh -c 'col -bx | ${_bat_cmd} --language=man --plain'"
export MANROFFOPT="-c"

# ── Native config auto-generate ─────────────────────────────────────────────
function _bat_generate_config() {
  local config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/bat"
  local config_file="${config_dir}/config"
  [[ -s "$config_file" ]] && return 0
  mkdir -p "$config_dir" 2>/dev/null
  cat > "$config_file" << 'EOF'
--theme="Catppuccin Mocha"
--style="auto"
--italic-text=always
--map-syntax "*.conf:INI"
--map-syntax ".gitignore:Git Ignore"
--map-syntax "*.toml:TOML"
--map-syntax "justfile:Makefile"
--map-syntax "Justfile:Makefile"
--map-syntax ".envrc:Bash"
--map-syntax "*.zsh:Zsh"
EOF
}
_bat_generate_config

# ── Functions ────────────────────────────────────────────────────────────────

function help() { "$@" --help 2>&1 | ${_bat_cmd} --plain --language=help; }
function preview() { ${_bat_cmd} --style=numbers,changes --color=always "$@"; }
function baturl() { curl -sSL "$1" | ${_bat_cmd} --style=auto --language="${2:-}"; }
function bat-themes() {
  ${_bat_cmd} --list-themes | \
    fzf --preview="${_bat_cmd} --theme={} --color=always ${ZDOTDIR}/.zshrc 2>/dev/null" \
        --header='Select bat theme'
}
function bat-regen() { rm -f "${XDG_CONFIG_HOME:-${HOME}/.config}/bat/config"; _bat_generate_config; log_info "bat config regenerated"; }

log_debug "bat configured"
