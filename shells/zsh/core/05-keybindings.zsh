#!/usr/bin/env zsh
# ============================================================================
# @file        core/05-keybindings.zsh
# @description ZSH key bindings configuration. Sets up a hybrid editing mode
#              that defaults to Emacs-style bindings with vi-mode support.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.1.0
#
# @see         https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html
# @depends     lib/logging.zsh
# @changelog   1.1.0 — Removed autosuggest-accept bindkey (moved to
#              plugins/03-syntax.zsh atload to avoid "unhandled ZLE widget")
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_KEYBINDINGS_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_KEYBINDINGS_LOADED=1

log_debug "Configuring key bindings"

# ============================================================================
# Keymap Selection — Emacs mode as default
# ============================================================================

bindkey -e

# ============================================================================
# Terminal Key Code Detection
# ============================================================================

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# @type associative array
# @description Map of logical key names to terminfo capabilities.
typeset -gA key_info
key_info=(
  Up        "${terminfo[kcuu1]:-$'\e[A'}"
  Down      "${terminfo[kcud1]:-$'\e[B'}"
  Left      "${terminfo[kcub1]:-$'\e[D'}"
  Right     "${terminfo[kcuf1]:-$'\e[C'}"
  Home      "${terminfo[khome]:-$'\e[H'}"
  End       "${terminfo[kend]:-$'\e[F'}"
  Insert    "${terminfo[kich1]:-$'\e[2~'}"
  Delete    "${terminfo[kdch1]:-$'\e[3~'}"
  PageUp    "${terminfo[kpp]:-$'\e[5~'}"
  PageDown  "${terminfo[knp]:-$'\e[6~'}"
  BackTab   "${terminfo[kcbt]:-$'\e[Z'}"
  Backspace "${terminfo[kbs]:-$'\x7f'}"
)

# ============================================================================
# Navigation — Cursor Movement
# ============================================================================

bindkey "${key_info[Home]}"  beginning-of-line
bindkey "${key_info[End]}"   end-of-line

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

bindkey '^[[1;5D' backward-word    # Ctrl-Left
bindkey '^[[1;5C' forward-word     # Ctrl-Right

bindkey '^[b' backward-word        # Alt-B
bindkey '^[f' forward-word         # Alt-F

bindkey '^[[1;3D' backward-word    # Alt-Left
bindkey '^[[1;3C' forward-word     # Alt-Right

# ============================================================================
# Editing — Text Manipulation
# ============================================================================

bindkey "${key_info[Delete]}" delete-char

bindkey "${key_info[Backspace]}" backward-delete-char
bindkey '^H' backward-delete-char

bindkey '^W' backward-kill-word
bindkey '^[d' kill-word
bindkey '^U' backward-kill-line
bindkey '^K' kill-line
bindkey '^Y' yank
bindkey '^T' transpose-chars
bindkey '^[t' transpose-words
bindkey '^[u' up-case-word
bindkey '^[l' down-case-word
bindkey '^[c' capitalize-word

# ============================================================================
# History — Navigation & Search
# ============================================================================

bindkey "${key_info[Up]}"   up-line-or-beginning-search
bindkey "${key_info[Down]}" down-line-or-beginning-search

bindkey '^P' up-line-or-beginning-search
bindkey '^N' down-line-or-beginning-search

bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

bindkey "${key_info[PageUp]}"   beginning-of-buffer-or-history
bindkey "${key_info[PageDown]}" end-of-buffer-or-history

# ============================================================================
# Completion — Tab Behavior
# ============================================================================

bindkey '^I' expand-or-complete
bindkey "${key_info[BackTab]}" reverse-menu-complete

# NOTE: autosuggest-accept (Ctrl-Space) is bound in plugins/03-syntax.zsh
# inside the autosuggestions plugin atload callback, AFTER the widget exists.
# Binding it here causes "unhandled ZLE widget 'autosuggest-accept'" errors.

# ============================================================================
# Utility Widgets
# ============================================================================

bindkey '^L' clear-screen

# @description Ctrl-Z — Toggle foreground/background
function _zsh_toggle_fg_bg() {
  if [[ -n "$(jobs)" ]]; then
    fg 2>/dev/null
  fi
}
zle -N _zsh_toggle_fg_bg
bindkey '^Z' _zsh_toggle_fg_bg

# @description Ctrl-X Ctrl-E — Edit command in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# @description Alt-. — Insert last argument from previous command
bindkey '^[.' insert-last-word

# @description Alt-H — Show help/man for current command
autoload -Uz run-help
(( $+aliases[run-help] )) && unalias run-help
bindkey '^[h' run-help

# ============================================================================
# Copy/Paste Integration (cross-platform)
# ============================================================================

# @description Copy current command line to system clipboard
function _copy_line_to_clipboard() {
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    printf '%s' "$BUFFER" | pbcopy
  elif [[ "$ZSH_PLATFORM" == "wsl" ]]; then
    printf '%s' "$BUFFER" | clip.exe
  elif command -v xclip &>/dev/null; then
    printf '%s' "$BUFFER" | xclip -selection clipboard
  elif command -v wl-copy &>/dev/null; then
    printf '%s' "$BUFFER" | wl-copy
  fi
  zle -M "Copied to clipboard"
}
zle -N _copy_line_to_clipboard
bindkey '^X^C' _copy_line_to_clipboard

# @description Paste from system clipboard into command line
function _paste_from_clipboard() {
  local paste_content
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    paste_content="$(pbpaste)"
  elif [[ "$ZSH_PLATFORM" == "wsl" ]]; then
    paste_content="$(powershell.exe -NoProfile -Command Get-Clipboard 2>/dev/null | tr -d '\r')"
  elif command -v xclip &>/dev/null; then
    paste_content="$(xclip -selection clipboard -o)"
  elif command -v wl-paste &>/dev/null; then
    paste_content="$(wl-paste)"
  fi
  LBUFFER+="${paste_content}"
}
zle -N _paste_from_clipboard
bindkey '^X^P' _paste_from_clipboard

# ============================================================================
# Ensure Terminal Application Mode
# ============================================================================

if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi

log_debug "Key bindings configured (keymap=emacs)"
