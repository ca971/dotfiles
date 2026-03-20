#!/usr/bin/env zsh
# ============================================================================
# @file        tools/ripgrep.zsh
# @description Ripgrep (grep replacement) — auto-setup + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_RIPGREP_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_RIPGREP_LOADED=1

has "rg" || return 0
log_debug "Configuring ripgrep"


# ── Native config ───────────────────────────────────────────────────────────
function _rg_generate_config() {
  local config_file="${RIPGREP_CONFIG_PATH:-${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/config}"
  [[ -s "$config_file" ]] && return 0
  mkdir -p "$(dirname "$config_file")" 2>/dev/null
  cat > "$config_file" << 'EOF'
--smart-case
--hidden
--follow
--glob=!.git
--glob=!node_modules
--glob=!__pycache__
--glob=!*.pyc
--glob=!.cache
--glob=!target
--glob=!dist
--glob=!build
--colors=line:fg:yellow
--colors=path:fg:green
--colors=match:fg:red
--colors=match:style:bold
EOF
}
_rg_generate_config

# ── Functions ────────────────────────────────────────────────────────────────
function rgcount() { rg --smart-case --hidden --follow --glob '!.git' --count "$@" | sort -t: -k2 -n -r; }
function rgtodo()  { rg '(TODO|FIXME|HACK|XXX|BUG|OPTIMIZE):?' "${1:-.}" --color=always; }
function rgi() {
  has "fzf" || { log_warn "fzf required"; return 1; }
  local prefix="rg --column --line-number --no-heading --color=always --smart-case --hidden --follow --glob '!.git'"
  fzf --ansi --disabled --query "${1:-}" \
    --bind "start:reload:${prefix} {q} || true" \
    --bind "change:reload:sleep 0.1; ${prefix} {q} || true" \
    --delimiter ':' \
    --preview 'bat --color=always --highlight-line {2} --line-range={2}: {1} 2>/dev/null' \
    --preview-window 'right:55%:+{2}-5:wrap' \
    --header='Live grep' \
    --bind "enter:become(${EDITOR:-nvim} {1} +{2})"
}
function rg-regen() { rm -f "${RIPGREP_CONFIG_PATH:-${XDG_CONFIG_HOME:-${HOME}/.config}/ripgrep/config}"; _rg_generate_config; log_info "ripgrep config regenerated"; }

log_debug "ripgrep configured"
