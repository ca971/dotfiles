#!/usr/bin/env zsh
# ============================================================================
# @file        shells/zsh/.zshrc
# @description ZSH configuration — sources shared resources + ZSH-specific.
#              Only contains what is UNIQUE to ZSH.
# @version     3.0.0
# ============================================================================

# ── Startup timer ────────────────────────────────────────────────────────────
typeset -gi _ZSH_START_MS=0
zmodload -F zsh/datetime p:EPOCHREALTIME 2>/dev/null && \
  _ZSH_START_MS=$(( ${EPOCHREALTIME%.*} * 1000 + ${${EPOCHREALTIME#*.}[1,3]} )) || \
  _ZSH_START_MS=$(( $(date +%s) * 1000 ))

export DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"

# ── Helpers ──────────────────────────────────────────────────────────────────
_source_if_exists() { [[ -f "$1" ]] && source "$1"; }
_source_dir()       { [[ -d "$1" ]] && for f in "$1"/*.zsh(N); do source "$f"; done; }

# ── Phase 1: Libraries ──────────────────────────────────────────────────────
source "${DOTFILES_DIR}/lib/logging.zsh"
source "${DOTFILES_DIR}/lib/platform-detect.zsh"
source "${DOTFILES_DIR}/lib/tool-check.zsh"
_source_if_exists "${DOTFILES_DIR}/lib/lazy-load.zsh"
_source_if_exists "${DOTFILES_DIR}/lib/toml-parser.zsh"

log_section "Dotfiles v${ZSH_CONFIG_VERSION} (ZSH)"

# ── Phase 2: Shared env (POSIX) ─────────────────────────────────────────────
_source_if_exists "${DOTFILES_DIR}/shells/shared/env.sh"
_source_if_exists "${DOTFILES_DIR}/shells/shared/path.sh"

# ── Phase 3: ZSH Core (options, history, completion, keys, security, perf) ──
log_section "Core Configuration"
_source_dir "${ZDOTDIR}/core"

# ── Phase 4: SSOT Generated (aliases, colors, icons, highlights) ─────────────
log_section "SSOT Generated Files"
_source_dir "${DOTFILES_DIR}/generated"

# ── Phase 5: Plugins (ZSH-specific) ─────────────────────────────────────────
log_section "Plugin Management"
_source_dir "${ZDOTDIR}/plugins"

# ── Phase 6: Tools (each file has its own guard) ─────────────────────────────
log_section "Tool Integrations"
for _tf in "${DOTFILES_DIR}"/tools/*.zsh(N); do source "$_tf"; done
unset _tf

# ── Phase 7: Functions ───────────────────────────────────────────────────────
log_section "Custom Functions"
_source_dir "${DOTFILES_DIR}/functions"

# ── Phase 8: Starship theme (shared POSIX selector) ─────────────────────────
_source_if_exists "${DOTFILES_DIR}/themes/starship-selector.zsh"

# ── Phase 9: Terminal (ZSH-specific) ────────────────────────────────────────
log_section "Terminal Adaptation"
[[ -f "${ZDOTDIR}/terminal/${ZSH_TERMINAL}.zsh" ]] && \
  source "${ZDOTDIR}/terminal/${ZSH_TERMINAL}.zsh"

# ── Phase 10: FZF theme ─────────────────────────────────────────────────────
_source_if_exists "${DOTFILES_DIR}/themes/fzf-theme.zsh"

# ── Phase 11: Local overrides ───────────────────────────────────────────────
log_section "Local Overrides"
_source_if_exists "${DOTFILES_DIR}/local/local.zsh"
_source_if_exists "${DOTFILES_DIR}/local/secrets.zsh"

# ── Starship failsafe ───────────────────────────────────────────────────────
if [[ -z "${_ZSH_TOOLS_STARSHIP_LOADED:-}" ]] && command -v starship &>/dev/null; then
  export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${DOTFILES_DIR}/themes/starship-powerline.toml}"
  eval "$(starship init zsh)"
fi

# ── Startup time ─────────────────────────────────────────────────────────────
if [[ "${ZSH_PROFILE:-0}" == "1" ]]; then zprof; fi
{
  local end_ms
  [[ -n "${EPOCHREALTIME:-}" ]] && end_ms=$(( ${EPOCHREALTIME%.*} * 1000 + ${${EPOCHREALTIME#*.}[1,3]} )) || end_ms=$(( $(date +%s) * 1000 ))
  local elapsed=$(( end_ms - _ZSH_START_MS ))
  (( elapsed > 0 && elapsed < 30000 )) && log_info "Shell startup completed in %dms" "$elapsed"
}
unset _ZSH_START_MS

# ── Fastfetch ────────────────────────────────────────────────────────────────
has "fastfetch" && [[ -z "${ZSH_NO_FASTFETCH:-}" ]] && [[ "${ZSH_IS_SSH:-0}" -eq 0 ]] && fastfetch
