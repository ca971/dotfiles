#!/usr/bin/env zsh
# ============================================================================
# @file        plugins/02-completions.zsh
# @description Completion enhancement plugins. Provides additional completion
#              definitions beyond the default ZSH set, and integrates with
#              Carapace for multi-shell completion bridging.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     plugins/00-zinit-bootstrap.zsh, core/04-completion.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_PLUGINS_COMPLETIONS_LOADED:-}" ]] && return 0
readonly _ZSH_PLUGINS_COMPLETIONS_LOADED=1

log_debug "Loading completion plugins"

# ============================================================================
# Community Completions — Massive collection of extra completions
# ============================================================================

# @description  zsh-completions provides ~300 additional completion definitions
#               for common tools not covered by the default ZSH distribution.
#               Loaded as source to ensure completions are available to compinit.
#               blockf = block the traditional fpath modification (Zinit handles it).
zinit ice wait"0" lucid blockf atpull"zinit creinstall -q ."
zinit light zsh-users/zsh-completions

# ============================================================================
# Docker Completions — Container ecosystem
# ============================================================================

# @description  Docker CLI completions (official from Docker)
zinit ice wait"1" lucid as"completion"
zinit snippet OMZP::docker/completions/_docker

# @description  Docker Compose completions
zinit ice wait"1" lucid as"completion"
zinit snippet OMZP::docker-compose/_docker-compose

# ============================================================================
# Kubernetes Completions
# ============================================================================

# @description  kubectl completions — loaded only if kubectl is available
if has "kubectl"; then
  zinit ice wait"1" lucid as"completion" id-as"kubectl-completion" \
    atclone"kubectl completion zsh > _kubectl" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# @description  Helm completions — loaded only if helm is available
if has "helm"; then
  zinit ice wait"2" lucid as"completion" id-as"helm-completion" \
    atclone"helm completion zsh > _helm" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# ============================================================================
# Tool-Specific Completions (generated on-demand)
# ============================================================================

# @description  Rust/Cargo completions
if has "rustup"; then
  zinit ice wait"2" lucid as"completion" id-as"rustup-completion" \
    atclone"rustup completions zsh > _rustup; rustup completions zsh cargo > _cargo" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# @description  GitHub CLI completions
if has "gh"; then
  zinit ice wait"2" lucid as"completion" id-as"gh-completion" \
    atclone"gh completion -s zsh > _gh" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# @description  Just task runner completions
if has "just"; then
  zinit ice wait"2" lucid as"completion" id-as"just-completion" \
    atclone"just --completions zsh > _just" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# @description  Chezmoi completions
if has "chezmoi"; then
  zinit ice wait"2" lucid as"completion" id-as"chezmoi-completion" \
    atclone"chezmoi completion zsh > _chezmoi" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# @description  Podman completions (if podman is used instead of docker)
if has "podman"; then
  zinit ice wait"2" lucid as"completion" id-as"podman-completion" \
    atclone"podman completion zsh > _podman" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# @description  Topgrade completions
if has "topgrade"; then
  zinit ice wait"2" lucid as"completion" id-as"topgrade-completion" \
    atclone"topgrade --gen-completion zsh > _topgrade 2>/dev/null || true" \
    atpull"%atclone" \
    run-atpull
  zinit light zdharma-continuum/null
fi

# ============================================================================
# OMZ Completion Plugins — Pre-built completion sets
# ============================================================================

# @description  pip (Python) completions
zinit ice wait"2" lucid as"completion"
zinit snippet OMZP::pip/_pip

# @description  Terraform completions
zinit ice wait"2" lucid
zinit snippet OMZP::terraform

# @description  systemd completions (Linux only)
if [[ "$ZSH_PLATFORM" == "linux" ]] || [[ "$ZSH_PLATFORM" == "wsl" ]]; then
  zinit ice wait"2" lucid
  zinit snippet OMZP::systemd
fi

# @description  Homebrew completions (macOS / Linuxbrew)
if has "brew"; then
  zinit ice wait"2" lucid
  zinit snippet OMZP::brew
fi

# ============================================================================
# Completion Replay — Apply all accumulated completions
# ============================================================================

# @description  Replay compdefs that were deferred during async plugin loading.
#               This ensures all completions from turbo-loaded plugins are
#               properly registered after the initial compinit pass.
zinit ice wait"3" lucid atload"
  # -- Replay all stored compdefs
  zicompinit
  zicdreplay
  log_debug 'Completions replayed (zicompinit + zicdreplay)'
"
zinit light zdharma-continuum/null

log_debug "Completion plugins loaded"
