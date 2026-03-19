#!/usr/bin/env zsh
# ============================================================================
# @file        functions/update.zsh
# @description Universal update orchestrator. Provides a single command to
#              update the ZSH configuration, SSOT-generated files, plugins,
#              tools, and optionally the system packages.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_UPDATE_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_UPDATE_LOADED=1

# ============================================================================
# Main Update Orchestrator
# ============================================================================

# @description  Update everything — ZSH config, SSOT, plugins, tools.
#               Runs each update step in sequence with status reporting.
# @param  $1    string  (optional) Scope:
#                        "all"     — everything including system packages
#                        "config"  — ZSH config repo only
#                        "ssot"    — regenerate SSOT files only
#                        "plugins" — Zinit plugins only
#                        "tools"   — mise/cargo/pip managed tools
#                        "system"  — system packages only
# @return       void
function zsh-update() {
  local scope="${1:-all}"
  local start_time="${EPOCHREALTIME:-$(date +%s)}"

  printf "\n  🔄 ZSH Update — scope: %s\n" "$scope"
  printf "  ═══════════════════════════════════\n\n"

  local steps_total=0
  local steps_ok=0
  local steps_fail=0

  # -- Step runner helper
  _update_step() {
    local name="$1"
    shift
    (( steps_total++ ))
    printf "  [%d] %s..." "$steps_total" "$name"

    if "$@" 2>/dev/null; then
      printf " ✅\n"
      (( steps_ok++ ))
    else
      printf " ❌\n"
      (( steps_fail++ ))
    fi
  }

  # ── Config Update ──────────────────────────────────────────────────────
  if [[ "$scope" == "all" || "$scope" == "config" ]]; then
    _update_step "Pull ZSH config from Git" \
      git -C "${ZDOTDIR}" pull --rebase --autostash
  fi

  # ── SSOT Regeneration ──────────────────────────────────────────────────
  if [[ "$scope" == "all" || "$scope" == "ssot" ]]; then
    _update_step "Regenerate SSOT files" \
      bash "${ZDOTDIR}/ssot/generators/generate-all.sh"
  fi

  # ── Plugin Update ──────────────────────────────────────────────────────
  if [[ "$scope" == "all" || "$scope" == "plugins" ]]; then
    if (( ${+functions[zinit]} )); then
      _update_step "Update Zinit plugins" \
        zinit update --all --parallel
    fi
  fi

  # ── Tool Update ────────────────────────────────────────────────────────
  if [[ "$scope" == "all" || "$scope" == "tools" ]]; then
    # -- mise
    if has "mise"; then
      _update_step "Upgrade mise tools" \
        mise upgrade --yes
    fi

    # -- Zinit self-update
    if (( ${+functions[zinit]} )); then
      _update_step "Update Zinit itself" \
        zinit self-update
    fi

    # -- Atuin sync
    if has "atuin"; then
      _update_step "Sync Atuin history" \
        atuin sync
    fi

    # -- TLDR cache
    if has "tldr"; then
      _update_step "Update TLDR cache" \
        tldr --update
    fi
  fi

  # ── System Packages ────────────────────────────────────────────────────
  if [[ "$scope" == "all" || "$scope" == "system" ]]; then
    if has "topgrade"; then
      _update_step "System upgrade (topgrade)" \
        topgrade --yes --cleanup
    fi
  fi

  # ── Recompile ZSH Files ────────────────────────────────────────────────
  if [[ "$scope" == "all" || "$scope" == "config" || "$scope" == "ssot" ]]; then
    _update_step "Recompile ZSH files" \
      _recompile_zsh_files
  fi

  # ── Summary ────────────────────────────────────────────────────────────
  local end_time="${EPOCHREALTIME:-$(date +%s)}"
  local elapsed
  if [[ -n "${EPOCHREALTIME:-}" ]]; then
    elapsed=$(( (end_time - start_time) ))
    elapsed=$(printf "%.0f" "$elapsed")
  else
    elapsed=$(( end_time - start_time ))
  fi

  printf "\n  ═══════════════════════════════════\n"
  printf "  Total:   %d steps\n" "$steps_total"
  printf "  Success: %d ✅\n" "$steps_ok"
  if (( steps_fail > 0 )); then
    printf "  Failed:  %d ❌\n" "$steps_fail"
  fi
  printf "  Time:    %ds\n" "$elapsed"
  printf "  ═══════════════════════════════════\n\n"

  if (( steps_fail > 0 )); then
    log_warn "Some update steps failed — check output above"
  else
    log_success "All updates completed successfully"
  fi

  unfunction _update_step 2>/dev/null
}

# ============================================================================
# Internal Helper — Recompile ZSH Files
# ============================================================================

# @description  Recompile all .zsh files under ZDOTDIR for faster loading
# @return       void
function _recompile_zsh_files() {
  local count=0
  local file
  for file in "${ZDOTDIR}"/**/*.zsh(N) "${ZDOTDIR}"/.z*(N); do
    if [[ -f "$file" ]] && [[ ! "$file" == *".zwc"* ]]; then
      zcompile "$file" 2>/dev/null && (( count++ ))
    fi
  done
  log_debug "Recompiled %d ZSH files" "$count"
}

# ============================================================================
# Convenience Aliases
# ============================================================================

# @description  Quick config-only update
function zsh-update-config() { zsh-update config; }

# @description  Quick SSOT regeneration
function zsh-update-ssot() { zsh-update ssot; }

# @description  Quick plugin update
function zsh-update-plugins() { zsh-update plugins; }

# @description  Quick system update
function zsh-update-system() { zsh-update system; }

# @description  Show what would be updated (dry run)
# @return       void
function zsh-update-check() {
  printf "\n  🔍 Update Check\n"
  printf "  ─────────────────────────────────\n"

  # -- Check for config changes
  printf "  Config:    "
  if git -C "${ZDOTDIR}" fetch --dry-run 2>&1 | grep -q "."; then
    printf "updates available\n"
  else
    printf "up to date ✅\n"
  fi

  # -- Check for plugin updates
  printf "  Plugins:   "
  if (( ${+functions[zinit]} )); then
    printf "check with 'zinit update --all'\n"
  else
    printf "zinit not loaded\n"
  fi

  # -- Check for tool updates
  if has "mise"; then
    printf "  Mise:      "
    local outdated
    outdated=$(mise outdated 2>/dev/null | wc -l | tr -d ' ')
    if (( outdated > 0 )); then
      printf "%d tools outdated\n" "$outdated"
    else
      printf "up to date ✅\n"
    fi
  fi

  printf "  ─────────────────────────────────\n\n"
}

log_debug "Update functions loaded"
