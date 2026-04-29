#!/usr/bin/env zsh
# ============================================================================
# @file        tools/yt-dlp.zsh
# @description yt-dlp — Youtube videos downloader integration.
#              Auto-symlinks config from dotfiles repo.
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @version     1.1.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_YT_DLP_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_YT_DLP_LOADED=1

has "yt-dlp" || return 0
log_debug "Configuring yt-dlp"

# ── Constants ───────────────────────────────────────────────────────────────
readonly YT_DLP_SRC_DIR="${DOTFILES_DIR}/config/yt-dlp"
readonly YT_DLP_DST_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/yt-dlp"

# ── Auto-Setup Symlink ───────────────────────────────────────────────────────
function _yt_dlp_auto_setup() {
    local src="${YT_DLP_SRC_DIR}"
    [[ -d "$src" ]] || return 0

    # Ensure parent config dir exists
    [[ -d "${YT_DLP_DST_DIR:h}" ]] || mkdir -p "${YT_DLP_DST_DIR:h}"

    if [[ -d "$YT_DLP_DST_DIR" && ! -L "$YT_DLP_DST_DIR" ]]; then
        mv "$YT_DLP_DST_DIR" "${YT_DLP_DST_DIR}.bak.$(date +%s)" 2>/dev/null
    fi

    if [[ ! -L "$YT_DLP_DST_DIR" ]] || \
       [[ "$(readlink "$YT_DLP_DST_DIR" 2>/dev/null)" != "$src" ]]; then
        ln -sf "$src" "$YT_DLP_DST_DIR" 2>/dev/null
    fi
}
_yt_dlp_auto_setup

# ── Aliases ──────────────────────────────────────────────────────────────────

# Standard download (uses your config: 1080p, FR priority, cookies)
alias ytd="yt-dlp"

# Audio extraction (MP3 with high quality metadata)
alias yta="yt-dlp -x --audio-format mp3 --audio-quality 0"

# List available formats for a video
alias ytl="yt-dlp --list-formats"

# Update yt-dlp via uv (as per your setup)
alias yt-update="uv tool upgrade yt-dlp"

# ── Functions ────────────────────────────────────────────────────────────────

# @description Download video and force French audio/subs even if not default
function ytd-fr() {
    [[ $# -eq 0 ]] && { log_error "Usage: ytd-fr <url>"; return 1; }
    yt-dlp --audio-multilingual fr --write-auto-subs --sub-lang "fr" "$@"
}

# @description Download only the audio in French (MP3)
function yta-fr() {
    [[ $# -eq 0 ]] && { log_error "Usage: yta-fr <url>"; return 1; }
    yt-dlp -x --audio-format mp3 --audio-multilingual fr "$@"
}

# @description Search YouTube and download the first result (Video)
function yts() {
    [[ $# -eq 0 ]] && { log_error "Usage: yts <search keywords>"; return 1; }
    yt-dlp "ytsearch1:$*"
}

# @description Show yt-dlp configuration info
function yt-dlp-info() {
    printf "\n  📺  yt-dlp\n"
    printf "  ─────────────────────────────────\n"
    printf "  Source:    %s\n" "$YT_DLP_SRC_DIR"
    printf "  Version:   %s\n" "$(yt-dlp --version 2>/dev/null)"

    # Check for JavaScript Runtime (Essential for your setup)
    if has "deno"; then
        printf "  JS Runtime: ✅ Deno (%s)\n" "$(deno --version | head -1 | awk '{print $2}')"
    elif has "node"; then
        printf "  JS Runtime: ⚠️  Node.js (Deno is preferred for your config)\n"
    else
        printf "  JS Runtime: ❌ None found (Challenges will fail)\n"
    fi

    # Check for AtomicParsley (For metadata/thumbnails)
    if has "AtomicParsley"; then
        printf "  Metadata:   ✅ AtomicParsley installed\n"
    else
        printf "  Metadata:   ⚠️  AtomicParsley missing (using ffmpeg fallback)\n"
    fi

    # Symlink status
    if [[ -L "$YT_DLP_DST_DIR" ]]; then
        printf "  Config:    ✅ ~/.config/yt-dlp → %s\n" "$(readlink "$YT_DLP_DST_DIR" | sed "s|${DOTFILES_DIR}|dotfiles|")"
    else
        printf "  Config:    ❌ ~/.config/yt-dlp not linked\n"
    fi
    printf "  ─────────────────────────────────\n\n"
}

log_debug "yt-dlp configured"
