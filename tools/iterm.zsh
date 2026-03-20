#!/usr/bin/env zsh
# ============================================================================
# @file        tools/iterm.zsh
# @description iTerm2 — shell integration + proprietary features.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_ITERM_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_ITERM_LOADED=1

[[ "${TERM_PROGRAM:-}" == "iTerm.app" ]] || return 0
log_debug "Configuring iterm"


# ── Shell integration ────────────────────────────────────────────────────────
local _ii="${HOME}/.iterm2_shell_integration.zsh"
[[ -f "$_ii" ]] && source "$_ii"

# ── Functions ────────────────────────────────────────────────────────────────

# @description  Set iTerm2 badge text
function iterm-badge() {
  printf '\e]1337;SetBadgeFormat=%s\e\\' "$(echo -n "${1:-}" | base64)"
}

# @description  Set tab color
function iterm-tab-color() {
  local r="${1:?r}" g="${2:?g}" b="${3:?b}"
  printf '\e]6;1;bg;red;brightness;%d\e\\' "$r"
  printf '\e]6;1;bg;green;brightness;%d\e\\' "$g"
  printf '\e]6;1;bg;blue;brightness;%d\e\\' "$b"
}

# @description  Reset tab color
function iterm-tab-color-reset() {
  printf '\e]6;1;bg;*;default\e\\'
}

# @description  Switch iTerm2 profile
function iterm-profile() {
  printf '\e]1337;SetProfile=%s\e\\' "${1:?Usage: iterm-profile <name>}"
}

# @description  Inline image display (iTerm2 protocol)
function icat() {
  if [[ ! -f "$1" ]]; then log_error "File not found: %s" "${1:-}"; return 1; fi
  if has "imgcat"; then
    imgcat "$@"
  else
    local data filename
    data=$(base64 < "$1")
    filename=$(basename "$1")
    printf '\e]1337;File=name=%s;inline=1:%s\a' "$(echo -n "$filename" | base64)" "$data"
  fi
}

# @description  Send notification
function iterm-notify() {
  printf '\e]9;%s\e\\' "${1:-Notification}"
}

# @description  Mark current position (Cmd+Shift+Up/Down navigation)
function iterm-mark() {
  printf '\e]133;A\e\\'
}

function iterm-info() {
  printf "\n  🖥️  iTerm2\n"
  printf "  ─────────────────────────────────\n"
  printf "  Integration: %s\n" "$([[ -f "${HOME}/.iterm2_shell_integration.zsh" ]] && echo '✅ loaded' || echo '❌ not installed')"
  printf "  Profile:     %s\n" "${ITERM_PROFILE:-default}"
  printf "  ─────────────────────────────────\n\n"
}

log_debug "iterm configured"
