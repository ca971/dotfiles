#!/usr/bin/env zsh
# ============================================================================
# @file        themes/fzf-theme.zsh
# @description FZF color theme configuration. Provides named theme presets
#              derived from the SSOT color palette. Allows runtime theme
#              switching for FZF's appearance.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_THEMES_FZF_LOADED:-}" ]] && return 0
readonly _ZSH_THEMES_FZF_LOADED=1

# ============================================================================
# Theme Definitions — Associative array of named FZF color schemes
# ============================================================================

# @type  associative array
# @description  Named FZF color schemes. Each value is a complete --color= string.
typeset -gA FZF_THEMES=(

  # ── Catppuccin Mocha (default) ─────────────────────────────────────────
  [catppuccin-mocha]="\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8\
,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc\
,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8\
,selected-bg:#45475a,border:#585b70,label:#cdd6f4"

  # ── Catppuccin Latte (light) ───────────────────────────────────────────
  [catppuccin-latte]="\
--color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39\
,fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78\
,marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39\
,selected-bg:#bcc0cc,border:#acb0be,label:#4c4f69"

  # ── Tokyo Night ────────────────────────────────────────────────────────
  [tokyonight]="\
--color=bg+:#292e42,bg:#1a1b26,spinner:#bb9af7,hl:#f7768e\
,fg:#c0caf5,header:#f7768e,info:#7aa2f7,pointer:#bb9af7\
,marker:#bb9af7,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e\
,selected-bg:#364a82,border:#545c7e,label:#c0caf5"

  # ── Gruvbox Dark ───────────────────────────────────────────────────────
  [gruvbox]="\
--color=bg+:#3c3836,bg:#282828,spinner:#fb4934,hl:#83a598\
,fg:#ebdbb2,header:#83a598,info:#fabd2f,pointer:#fb4934\
,marker:#fb4934,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598\
,selected-bg:#504945,border:#665c54,label:#ebdbb2"

  # ── Nord ───────────────────────────────────────────────────────────────
  [nord]="\
--color=bg+:#3b4252,bg:#2e3440,spinner:#81a1c1,hl:#bf616a\
,fg:#d8dee9,header:#bf616a,info:#88c0d0,pointer:#81a1c1\
,marker:#81a1c1,fg+:#eceff4,prompt:#88c0d0,hl+:#bf616a\
,selected-bg:#434c5e,border:#4c566a,label:#d8dee9"

  # ── Dracula ────────────────────────────────────────────────────────────
  [dracula]="\
--color=bg+:#44475a,bg:#282a36,spinner:#ff79c6,hl:#ff5555\
,fg:#f8f8f2,header:#ff5555,info:#bd93f9,pointer:#ff79c6\
,marker:#ff79c6,fg+:#f8f8f2,prompt:#bd93f9,hl+:#ff5555\
,selected-bg:#44475a,border:#6272a4,label:#f8f8f2"

  # ── Minimal (low-color, high contrast) ─────────────────────────────────
  [minimal]="\
--color=bg+:#333333,bg:#1a1a1a,spinner:#ffffff,hl:#ff6600\
,fg:#cccccc,header:#ff6600,info:#999999,pointer:#ffffff\
,marker:#ffffff,fg+:#ffffff,prompt:#ff6600,hl+:#ff8800\
,selected-bg:#444444,border:#555555,label:#cccccc"
)

# ============================================================================
# Theme Application
# ============================================================================

# @description  Apply a named FZF theme. Updates FZF_DEFAULT_OPTS to include
#               the selected color scheme.
# @param  $1    string  Theme name (key from FZF_THEMES)
# @return       0 on success, 1 if theme not found
function fzf-theme() {
  local theme="${1:-catppuccin-mocha}"

  if [[ -z "${FZF_THEMES[$theme]:-}" ]]; then
    log_error "Unknown FZF theme: %s" "$theme"
    log_info "Available themes: %s" "${(kj:, :)FZF_THEMES}"
    return 1
  fi

  # -- Strip existing --color= from FZF_DEFAULT_OPTS
  local opts_no_color
  opts_no_color=$(echo "$FZF_DEFAULT_OPTS" | sed 's/--color=[^ ]*//' | tr -s ' ')

  export FZF_DEFAULT_OPTS="${opts_no_color} ${FZF_THEMES[$theme]}"
  log_info "FZF theme set to: %s" "$theme"
}

# @description  Preview all available FZF themes interactively
# @return       void (applies the selected theme)
function fzf-theme-preview() {
  if ! has "fzf"; then
    log_warn "fzf required for theme preview"
    return 1
  fi

  local theme
  theme=$(printf "%s\n" "${(@k)FZF_THEMES}" | sort | \
    fzf --header='🎨 Select FZF theme' \
        --preview="echo 'Preview of theme: {}'
echo ''
echo 'Sample files:'
ls -la \$HOME 2>/dev/null | head -15" \
        --preview-window='right:50%:wrap')

  [[ -n "$theme" ]] && fzf-theme "$theme"
}

# ============================================================================
# Apply Default Theme
# ============================================================================

# @description  Apply the default theme on load (Catppuccin Mocha)
#               Only if FZF_DEFAULT_OPTS doesn't already contain --color=
if [[ "${FZF_DEFAULT_OPTS:-}" != *"--color="* ]]; then
  # -- Apply theme silently (no log_info during startup)
  local _current_theme="${FZF_THEME:-catppuccin-mocha}"
  if [[ -n "${FZF_THEMES[$_current_theme]:-}" ]]; then
    export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} ${FZF_THEMES[$_current_theme]}"
  fi
  unset _current_theme
fi

log_debug "FZF themes loaded (%d themes available)" "${#FZF_THEMES}"
