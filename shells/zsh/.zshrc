#!/usr/bin/env zsh
# ============================================================================
# @file        shells/zsh/.zshrc
# @description Main ZSH configuration orchestrator. Sources all modules in
#              the correct dependency order:
#
#              DOTFILES_DIR (shared)     ZDOTDIR (ZSH-specific)
#              ├── lib/*            →   ├── core/*
#              ├── generated/*           ├── plugins/*
#              ├── tools/*               └── terminal/*
#              ├── functions/*
#              ├── platform/*
#              └── local/*
#
#              This file is sourced for INTERACTIVE shells only.
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     2.0.0
#
# @changelog   2.0.0 — Restructured for cross-platform cross-shell dotfiles.
#              Shared resources loaded from DOTFILES_DIR.
#              ZSH-specific modules loaded from ZDOTDIR (shells/zsh/).
#              Clear separation between shared and shell-specific code.
#
# @note        Do NOT add configuration directly here. Place it in the
#              appropriate module:
#              - ZSH options/plugins → shells/zsh/core/ or shells/zsh/plugins/
#              - Tool integration    → tools/*.zsh (shared)
#              - Custom functions    → functions/*.zsh (shared)
#              - Platform-specific   → platform/*.zsh (shared)
#              - Terminal-specific   → shells/zsh/terminal/*.zsh
#              - Private/local       → local/*.zsh (gitignored)
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

# ── Phase 1: Libraries ───────────────────────────────────────────────────────
source "${DOTFILES_DIR}/lib/logging.zsh"
source "${DOTFILES_DIR}/lib/platform-detect.zsh"
source "${DOTFILES_DIR}/lib/tool-check.zsh"
_source_if_exists "${DOTFILES_DIR}/lib/lazy-load.zsh"
_source_if_exists "${DOTFILES_DIR}/lib/toml-parser.zsh"

log_section "Dotfiles v${ZSH_CONFIG_VERSION} (ZSH)"

# ── Phase 2: Shared env (POSIX) ──────────────────────────────────────────────
_source_if_exists "${DOTFILES_DIR}/shells/shared/env.sh"
_source_if_exists "${DOTFILES_DIR}/shells/shared/path.sh"

# ── Phase 3: ZSH Core (options, history, completion, keys, security, perf) ───
log_section "Core Configuration"
_source_dir "${ZDOTDIR}/core"

# ── Phase 4: SSOT Generated (aliases, colors, icons, highlights) ─────────────
log_section "SSOT Generated Files"
_source_dir "${DOTFILES_DIR}/generated"

# ── Phase 5: Plugins (ZSH-specific) ─────────────────────────────────────────
# NOTE: zsh-syntax-highlighting is intentionally excluded here.
# It will be loaded in Phase 12 (after all ZLE widgets from atuin and fzf)
# to avoid the “unhandled ZLE widget” error.
log_section "Plugin Management"
for _pf in "${ZDOTDIR}"/plugins/*.zsh(N); do
    [[ "$_pf:t" == *syntax-highlighting* ]] && continue
    source "$_pf"
done
unset _pf

# ── Phase 6: Tools (each file has its own guard) ─────────────────────────────
# NOTE: The alphabetical order is intentional and critical:
#   atuin.zsh (a) is loaded BEFORE fzf.zsh (f).
#   The safety net in fzf.zsh returns Ctrl+R to Atuin after fzf has initialized.
log_section "Tool Integrations"
for _tf in "${DOTFILES_DIR}"/tools/*.zsh(N); do
    source "$_tf"
done
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

# ── Phase 10: FZF theme ──────────────────────────────────────────────────────
_source_if_exists "${DOTFILES_DIR}/themes/fzf-theme.zsh"

# ── Phase 11: Local overrides ────────────────────────────────────────────────
log_section "Local Overrides"
_source_if_exists "${DOTFILES_DIR}/local/local.zsh"
_source_if_exists "${DOTFILES_DIR}/local/secrets.zsh"

# ── Phase 12: ZSH Syntax Highlighting (MUST BE LAST) ───────────────
# Must be loaded after ALL ZLE widgets (atuin-search, fzf, etc.)
# have been created. Otherwise: “zsh-syntax-highlighting: unhandled ZLE widget”.
log_section "Syntax Highlighting"
for _hl in "${ZDOTDIR}"/plugins/*syntax-highlighting*.zsh(N); do
    source "$_hl" && break
done
unset _hl

# ── Starship failsafe ────────────────────────────────────────────────────────
if [[ -z "${_ZSH_TOOLS_STARSHIP_LOADED:-}" ]] && command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-${DOTFILES_DIR}/themes/starship-powerline.toml}"
    eval "$(starship init zsh)"
fi

# ── Startup time ─────────────────────────────────────────────────────────────
if [[ "${ZSH_PROFILE:-0}" == "1" ]]; then zprof; fi
{
    local end_ms
    if [[ -n "${EPOCHREALTIME:-}" ]]; then
        end_ms=$(( ${EPOCHREALTIME%.*} * 1000 + ${${EPOCHREALTIME#*.}[1,3]} ))
    else
        end_ms=$(( $(date +%s) * 1000 ))
    fi
    local elapsed=$(( end_ms - _ZSH_START_MS ))
    (( elapsed > 0 && elapsed < 30000 )) && \
        log_info "Shell startup completed in %dms" "$elapsed"
}
unset _ZSH_START_MS

# ── Fastfetch ────────────────────────────────────────────────────────────────
has "fastfetch" && [[ -z "${ZSH_NO_FASTFETCH:-}" ]] && \
    [[ "${ZSH_IS_SSH:-0}" -eq 0 ]] && fastfetch

# opencode
export PATH=/Users/ca/.opencode/bin:$PATH
