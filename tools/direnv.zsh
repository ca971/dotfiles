#!/usr/bin/env zsh
# ============================================================================
# @file        tools/direnv.zsh
# @description Direnv (per-directory environments).
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_DIRENV_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_DIRENV_LOADED=1

has "direnv" || return 0
log_debug "Configuring direnv"


eval "$(direnv hook zsh)"

function direnv-init() {
  local tpl="${1:-basic}"
  [[ -f ".envrc" ]] && { log_warn ".envrc exists"; printf "Overwrite? [y/N] "; read -rk1 c; echo; [[ "${c:l}" != "y" ]] && return 0; }
  case "$tpl" in
    python) printf "layout python3\n" > .envrc ;;
    node)   printf "layout node\n" > .envrc ;;
    go)     printf "export GOBIN=\$PWD/bin\nPATH_add bin\n" > .envrc ;;
    rust)   printf "PATH_add target/debug\nPATH_add target/release\n" > .envrc ;;
    mise)   printf "use mise\n" > .envrc ;;
    *)      printf "# Project environment\n# export MY_VAR=\"value\"\n" > .envrc ;;
  esac
  direnv allow . && log_info "Created .envrc (%s)" "$tpl"
}
function direnv-edit()   { "${EDITOR:-nvim}" .envrc; direnv allow .; }
function direnv-reload() { direnv reload; log_info "Reloaded"; }

log_debug "direnv configured"
