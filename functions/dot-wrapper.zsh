#!/usr/bin/env zsh
# ============================================================================
# @file        functions/dot-wrapper.zsh
# @description Shell function wrapper for the dot CLI. Handles commands
#              that need to modify the current shell environment (theme, cd).
#              All other commands are delegated to bin/dot script.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-16
# @version     1.0.0
# ============================================================================

[[ -n "${_ZSH_DOT_WRAPPER_LOADED:-}" ]] && return 0
readonly _ZSH_DOT_WRAPPER_LOADED=1

# @description  Unified dotfiles CLI wrapper. Intercepts commands that
#               need to modify the current shell environment and handles
#               them in-process. Delegates everything else to bin/dot.
# @param  $1    string  Command name
# @param  $@    mixed   Command arguments
# @return       Depends on command
function dot() {
  local cmd="${1:-help}"

  case "$cmd" in
    # ── Theme: must run in current shell to export env vars ────────────
    theme|th)
      shift
      local action="${1:-}"

      case "$action" in
        powerline|minimal|nerd)
          local theme_file="${DOTFILES_DIR}/themes/starship-${action}.toml"
          if [[ -f "$theme_file" ]]; then
            export STARSHIP_CONFIG="$theme_file"
            export STARSHIP_THEME="$action"
            printf "  \033[38;2;166;227;161m✓\033[0m Theme \033[1m\033[38;2;203;166;247m%s\033[0m activated\n" "$action"
          else
            printf "  \033[38;2;243;139;168m✗\033[0m Theme not found: %s\n" "$action"
          fi
          ;;
        list|ls|l|preview|p)
          DOT_EXPORT_MODE=0 command dot theme "$@"
          ;;
        "")
          # Interactive: capture the selection and apply
          if (( $+commands[fzf] )); then
            local choice
            choice=$(printf "powerline\t  Powerline Rounded — workstation\nminimal\t  Minimal Two-Line — SSH/Docker\nnerd\t☸  Nerd Blocks — VPS/Proxmox/K8s\n" | \
              fzf --delimiter='\t' \
                  --with-nth=1.. \
                  --header="🎨 Current: ${STARSHIP_THEME:-unknown}" \
                  --preview="STARSHIP_CONFIG='${DOTFILES_DIR}/themes/starship-{1}.toml' starship prompt 2>/dev/null" \
                  --preview-window='up:3:wrap' \
                  --height='40%' \
                  --border=rounded \
                  --ansi | \
              cut -f1)
            [[ -n "$choice" ]] && dot theme "$choice"
          else
            printf "\n  🎨 Starship Themes (current: %s)\n\n" "${STARSHIP_THEME:-unknown}"
            printf "  1) powerline  — Powerline Rounded\n"
            printf "  2) minimal    — Minimal Two-Line\n"
            printf "  3) nerd       — Nerd Blocks\n\n"
            printf "  Choice [1-3]: "
            local choice
            read -r choice
            case "$choice" in
              1) dot theme powerline ;;
              2) dot theme minimal ;;
              3) dot theme nerd ;;
            esac
          fi
          ;;
        *)
          printf "  \033[38;2;243;139;168m✗\033[0m Unknown theme: %s\n" "$action"
          printf "  Available: powerline, minimal, nerd\n"
          ;;
      esac
      ;;

    # ── CD: must run in current shell ──────────────────────────────────
    cd)
      cd "${DOTFILES_DIR}" || return 1
      ;;

    # ── Everything else: delegate to bin/dot ───────────────────────────
    *)
      command dot "$@"
      ;;
  esac
}
