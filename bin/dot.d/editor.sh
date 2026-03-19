#!/usr/bin/env bash
# ============================================================================
# @file        bin/dot.d/editor.sh
# @description Editor management — info, update, reinstall for all
#              supported editors (Neovim + future editors).
# @version     1.0.0
# ============================================================================

cmd_editor() {
    local action="${1:-}"
    local editor="${2:-}"
    shift 2 2> /dev/null || true

    # ── Auto-detect editor if not specified ────────────────────────────
    [[ -z "$editor" ]] && editor="neovim"

    case "$action" in
        info)
            if [[ "$editor" == "all" ]]; then
                _banner
                _section "${I_CODE}  Editors"
                printf '  %b%-14s %-10s %-14s %s%b\n' "${S_BOLD}${C_TEXT}" "EDITOR" "STATUS" "VERSION" "CONFIG" "$S_RESET"
                _separator

                local e bin ver config_status
                for e in neovim vim helix; do
                    case "$e" in
                        neovim) bin="nvim" ;;
                        vim) bin="vim" ;;
                        helix) bin="hx" ;;
                    esac

                    if _has "$bin"; then
                        ver=$("$bin" --version 2> /dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
                        local dir="${XDG_CONFIG_HOME:-${HOME}/.config}/${e}"
                        [[ "$e" == "neovim" ]] && dir="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
                        [[ -d "${dir}/.git" ]] && config_status="✅ cloned" || config_status="📁 local"
                        printf '  %b%-14s%b ✅        %-14s %s\n' "$C_TEXT" "$e" "$S_RESET" "${ver:-?}" "$config_status"
                    else
                        printf '  %b%-14s ○%b\n' "$C_MUTED" "$e" "$S_RESET"
                    fi
                done
                printf '\n'
            else
                zsh -ic "${editor/neovim/nvim}-info" 2> /dev/null \
                    || zsh -ic "${editor}-info" 2> /dev/null \
                    || _err "Unknown editor: ${editor}"
            fi
            ;;

        update)
            if [[ "$editor" == "all" ]]; then
                _banner
                _section "${I_CODE}  Updating Editors"
                local nvim_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/nvim"
                if [[ -d "${nvim_dir}/.git" ]]; then
                    printf '  %b%b%b  neovim%b\n' "$C_BLUE" "$I_LOADING" "$S_RESET" "$S_RESET"
                    git -C "$nvim_dir" pull --rebase --quiet 2> /dev/null && _ok "neovim updated" || _warn "neovim failed"
                fi
                printf '\n'
            else
                zsh -ic "${editor/neovim/nvim}-update" 2> /dev/null \
                    || zsh -ic "${editor}-update" 2> /dev/null \
                    || _err "Unknown: ${editor}"
            fi
            ;;

        reinstall)
            zsh -ic "${editor/neovim/nvim}-reinstall" 2> /dev/null \
                || zsh -ic "${editor}-reinstall" 2> /dev/null \
                || _err "Unknown: ${editor}"
            ;;

        edit)
            case "$editor" in
                neovim | nvim) "${EDITOR:-nvim}" "${XDG_CONFIG_HOME:-${HOME}/.config}/nvim/init.lua" ;;
                helix | hx) "${EDITOR:-nvim}" "${XDG_CONFIG_HOME:-${HOME}/.config}/helix/config.toml" ;;
                *) _err "Unknown: ${editor}" ;;
            esac
            ;;

        health)
            case "$editor" in
                neovim | nvim) nvim "+checkhealth" "+only" ;;
                *) _err "Health check not available for: ${editor}" ;;
            esac
            ;;

        list | ls)
            _banner
            _section "${I_CODE}  Supported Editors"
            printf '  %bneovim%b       %bhttps://neovim.io%b\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            printf '  %bhelix%b        %bhttps://helix-editor.com%b\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            printf '  %bvim%b          %bhttps://www.vim.org%b\n\n' "$C_TEAL" "$S_RESET" "$C_OVERLAY" "$S_RESET"
            ;;

        *)
            printf '\n  %b%b%b  Editor Management%b\n\n' "$S_BOLD" "$C_TEXT" "$I_CODE" "$S_RESET"
            printf '    %binfo%b [name|all]    Editor info (default: neovim)\n' "$C_TEAL" "$S_RESET"
            printf '    %bupdate%b [name|all]  Update editor config\n' "$C_TEAL" "$S_RESET"
            printf '    %breinstall%b <name>   Remove and reclone config\n' "$C_TEAL" "$S_RESET"
            printf '    %bedit%b [name]        Edit editor config\n' "$C_TEAL" "$S_RESET"
            printf '    %bhealth%b [name]      Run health check\n' "$C_TEAL" "$S_RESET"
            printf '    %blist%b               Show supported editors\n\n' "$C_TEAL" "$S_RESET"
            printf '  %bExamples:%b\n' "$S_BOLD" "$S_RESET"
            printf '    %bdot editor%b                 Neovim info\n' "$C_OVERLAY" "$S_RESET"
            printf '    %bdot editor info all%b        All editors info\n' "$C_OVERLAY" "$S_RESET"
            printf '    %bdot editor update%b          Update neovim config\n' "$C_OVERLAY" "$S_RESET"
            printf '    %bdot editor health%b          Run neovim health check\n' "$C_OVERLAY" "$S_RESET"
            printf '    %bdot editor reinstall nvim%b  Reinstall neovim config\n\n' "$C_OVERLAY" "$S_RESET"
            ;;
    esac
}
