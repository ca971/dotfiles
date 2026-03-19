#!/usr/bin/env zsh
# ============================================================================
# @file        core/04-completion.zsh
# @description ZSH completion system (compsys) configuration. Sets up the
#              powerful zsh completion system with smart caching, fuzzy
#              matching, grouping, and visual styling. This is the native
#              completion layer; Carapace integration is in tools/carapace.zsh.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @see         https://zsh.sourceforge.io/Doc/Release/Completion-System.html
# @depends     lib/logging.zsh, core/00-xdg.zsh
# ============================================================================

# ── Guard: prevent double-sourcing ───────────────────────────────────────────
[[ -n "${_ZSH_CORE_COMPLETION_LOADED:-}" ]] && return 0
readonly _ZSH_CORE_COMPLETION_LOADED=1

log_debug "Configuring completion system"

# ============================================================================
# Completion Dump File — XDG-compliant cache
# ============================================================================

# @description Path to the completion dump file (cached state of compinit)
typeset -g _ZSH_COMPDUMP="${ZSH_CACHE_DIR}/zcompdump-${ZSH_VERSION}"

# ============================================================================
# Completion Directories — Additional function paths
# ============================================================================

# @description Add custom completion directories to fpath
typeset -gU fpath

# -- User completions
[[ -d "${ZDOTDIR}/completions" ]] && fpath=("${ZDOTDIR}/completions" $fpath)

# -- Homebrew completions (macOS / Linuxbrew)
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  [[ -d "${HOMEBREW_PREFIX}/share/zsh/site-functions" ]] && \
    fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)
  [[ -d "${HOMEBREW_PREFIX}/share/zsh-completions" ]] && \
    fpath=("${HOMEBREW_PREFIX}/share/zsh-completions" $fpath)
fi

# -- Nix completions
[[ -d "${HOME}/.nix-profile/share/zsh/site-functions" ]] && \
  fpath=("${HOME}/.nix-profile/share/zsh/site-functions" $fpath)

# ============================================================================
# Initialize Completion System
# ============================================================================

# @description Load and initialize the completion system with caching.
#              Only regenerates the dump file once per day to avoid slow
#              startup from scanning all completion functions.
autoload -Uz compinit

# -- Check if dump file needs regeneration (older than 24 hours)
if [[ -f "$_ZSH_COMPDUMP" ]]; then
  local _dump_age
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    _dump_age=$(( $(date +%s) - $(stat -f%m "$_ZSH_COMPDUMP" 2>/dev/null || echo 0) ))
  else
    _dump_age=$(( $(date +%s) - $(stat -c%Y "$_ZSH_COMPDUMP" 2>/dev/null || echo 0) ))
  fi

  if (( _dump_age > 86400 )); then
    # -- Older than 24h: full regeneration
    log_debug "Completion dump stale (%ds old), regenerating" "$_dump_age"
    compinit -d "$_ZSH_COMPDUMP"
  else
    # -- Recent: load without security check for speed
    compinit -C -d "$_ZSH_COMPDUMP"
  fi
  unset _dump_age
else
  # -- No dump file: full initialization
  log_debug "No completion dump found, generating"
  compinit -d "$_ZSH_COMPDUMP"
fi

# ============================================================================
# Completion Styles (zstyle)
# ============================================================================

# ── General ──────────────────────────────────────────────────────────────────

# @description Use caching for expensive completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}/zcompcache"

# @description Select completers in priority order
zstyle ':completion:*' completer _extensions _complete _approximate _ignored

# @description Complete options after -- for all commands
zstyle ':completion:*' complete-options true

# ── Matching & Fuzzy ─────────────────────────────────────────────────────────

# @description Smart case-insensitive and fuzzy matching
#   1. Try exact match
#   2. Try case-insensitive
#   3. Try partial word completion (f.b → foo-bar)
#   4. Try substring matching
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# @description Maximum errors allowed for approximate matching (scales with word length)
zstyle ':completion:*:approximate:*' max-errors 2 numeric

# ── Formatting & Display ────────────────────────────────────────────────────

# @description Group completion results by category
zstyle ':completion:*' group-name ''

# @description Format strings for different completion contexts
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:corrections'  format '%F{green}── %d (errors: %e) ──%f'
zstyle ':completion:*:messages'     format '%F{blue}── %d ──%f'
zstyle ':completion:*:warnings'     format '%F{red}── No matches found ──%f'

# @description Use a visual menu for completion selection
zstyle ':completion:*' menu select

# @description Show descriptions for options
zstyle ':completion:*' verbose true

# @description List completion results with colors (LS_COLORS)
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS:-}"

# @description Squeeze consecutive slashes in paths
zstyle ':completion:*' squeeze-slashes true

# ── File & Directory Completion ──────────────────────────────────────────────

# @description Complete files with common patterns
zstyle ':completion:*:*:*:*:files' ignored-patterns \
  '*.pyc' '*.pyo' '__pycache__' \
  '*.o' '*.obj' '*.a' '*.lib' \
  '.DS_Store' 'Thumbs.db' \
  '*.zwc' '*.zwc.old' \
  'node_modules' '.git'

# @description Directories first in file listing
zstyle ':completion:*' list-dirs-first true

# @description Special completion for cd — only directories
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# @description Use full path expansion for cd
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# ── Process Completion ───────────────────────────────────────────────────────

# @description Show process details in kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# @description Show all user processes in kill/signal completion
if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
  zstyle ':completion:*:processes' command 'ps -u $USER -o pid,stat,%cpu,%mem,cputime,command'
else
  zstyle ':completion:*:processes' command 'ps -u $USER -o pid,stat,%cpu,%mem,time,args'
fi

# ── SSH / Hosts Completion ───────────────────────────────────────────────────

# @description Gather hosts from SSH config and known_hosts
zstyle ':completion:*:ssh:*' hosts off  # Disable slow hostname lookups
zstyle ':completion:*:scp:*' hosts off

# @description Use SSH config for host completion
if [[ -f "${HOME}/.ssh/config" ]] || [[ -f "${XDG_CONFIG_HOME}/ssh/config" ]]; then
  zstyle ':completion:*:ssh:*' config true
fi

# ── Man Pages ────────────────────────────────────────────────────────────────

# @description Complete man pages by section
zstyle ':completion:*:manuals'   separate-sections true
zstyle ':completion:*:manuals.*' insert-sections   true

# ── User Completion ──────────────────────────────────────────────────────────

# @description Complete users (limit to relevant users)
zstyle ':completion:*:*:*:users' ignored-patterns \
  avahi bin colord daemon dbus ftp gdm haldaemon halt http \
  mail messagebus mysql nobody ntp polkitd postfix postgres \
  pulse rtkit sddm shutdown squid sshd sync systemd-bus-proxy \
  systemd-coredump systemd-journal-gateway systemd-journal-remote \
  systemd-journal-upload systemd-network systemd-resolve systemd-timesync \
  usbmux uuidd www-data '_*'

# ── Docker / Kubernetes ─────────────────────────────────────────────────────

# @description Docker container/image name completion caching
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes

# ── Environment Variables ───────────────────────────────────────────────────

# @description Sort environment variable completion
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' \
  'path-directories' 'users' 'expand'

# ============================================================================
# Completion Initialization Post-Processing
# ============================================================================

# @description Load bash-compatible completions if needed
autoload -Uz bashcompinit && bashcompinit

log_debug "Completion system configured (dump=%s)" "$_ZSH_COMPDUMP"
