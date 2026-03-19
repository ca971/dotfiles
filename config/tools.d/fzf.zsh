# ============================================================================
# FZF — options & keybindings
# @see https://github.com/junegunn/fzf
# ============================================================================

# ── Default command ──────────────────────────────────────────────────────────
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --strip-cwd-prefix --exclude .git --exclude node_modules"
  export FZF_CTRL_T_COMMAND="fd --type f --type d --hidden --follow --strip-cwd-prefix --exclude .git"
  export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --strip-cwd-prefix --exclude .git"
fi

# ── Default options ──────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS="\
  --height=70% \
  --layout=reverse \
  --border=rounded \
  --info=inline-right \
  --prompt='  ' \
  --pointer='▶' \
  --marker='✓' \
  --separator='─' \
  --scrollbar='▐' \
  --bind='ctrl-/:toggle-preview' \
  --bind='ctrl-a:select-all' \
  --bind='ctrl-d:deselect-all' \
  --bind='ctrl-u:preview-half-page-up' \
  --bind='ctrl-f:preview-half-page-down' \
  --preview-window='right:55%:border-left:wrap' \
  --history='${XDG_STATE_HOME:-${HOME}/.local/state}/fzf_history' \
  --history-size=10000 \
  --color='fg:-1,bg:-1,hl:#5f87af,fg+:#d75f00,bg+:-1,hl+:#d75f00' \
  --color='info:#af87ff,prompt:#5fff00,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7'
  "

# ── Ctrl-T preview ──────────────────────────────────────────────────────────
export FZF_CTRL_T_OPTS="\
  --preview='[[ -d {} ]] && eza --icons --tree --level=1 --color=always {} || bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}' \
  --header='Select files'"

# ── Ctrl-R options ──────────────────────────────────────────────────────────
export FZF_CTRL_R_OPTS="\
  --preview='echo {}' \
  --preview-window='up:3:wrap:hidden' \
  --bind='ctrl-/:toggle-preview' \
  --header='History' \
  --exact"

# ── Alt-C options ────────────────────────────────────────────────────────────
export FZF_ALT_C_OPTS="\
  --preview='eza --icons --tree --level=2 --color=always {} 2>/dev/null || ls -la {}' \
  --header='Jump to directory'"
