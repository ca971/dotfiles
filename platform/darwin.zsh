#!/usr/bin/env zsh
# ============================================================================
# @file        platform/darwin.zsh
# @description macOS-specific configuration. Configures Homebrew integration,
#              macOS system utilities, Finder/Spotlight shortcuts, clipboard
#              enhancements, and Apple Silicon optimizations.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/platform-detect.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_PLATFORM_DARWIN_LOADED:-}" ]] && return 0
readonly _ZSH_PLATFORM_DARWIN_LOADED=1

[[ "$ZSH_PLATFORM" == "darwin" ]] || return 0

log_debug "Loading macOS platform configuration"

# ============================================================================
# Homebrew — Package manager integration
# ============================================================================

# @description  Homebrew environment (already bootstrapped in core/01-platform.zsh)
#               Additional Homebrew aliases and settings.

# @description  Homebrew privacy settings
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_AUTOREMOVE=1
export HOMEBREW_NO_INSECURE_REDIRECT=1
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# @description  Homebrew aliases
alias brewup="brew update && brew upgrade && brew cleanup --prune=7"
alias brewi="brew install"
alias brews="brew search"
alias brewinfo="brew info"
alias brewls="brew list"
alias brewdeps="brew deps --tree --installed"

# @description  Homebrew bundle (Brewfile management)
alias brewdump="brew bundle dump --file=${XDG_CONFIG_HOME}/homebrew/Brewfile --force"
alias brewbundle="brew bundle --file=${XDG_CONFIG_HOME}/homebrew/Brewfile"

# @description  Interactive Homebrew search and install via FZF
# @return       void
function brewfzf() {
  if ! has "fzf"; then
    brew search "$@"
    return
  fi

  local formula
  formula=$(brew formulae | fzf --multi \
    --header='🍺 Select formulae to install' \
    --preview='brew info {} 2>/dev/null' \
    --preview-window='right:60%:wrap')

  if [[ -n "$formula" ]]; then
    echo "$formula" | xargs brew install
  fi
}

# @description  Interactive Homebrew cask search and install via FZF
# @return       void
function caskfzf() {
  if ! has "fzf"; then
    brew search --cask "$@"
    return
  fi

  local cask
  cask=$(brew casks | fzf --multi \
    --header='🍺 Select casks to install' \
    --preview='brew info --cask {} 2>/dev/null' \
    --preview-window='right:60%:wrap')

  if [[ -n "$cask" ]]; then
    echo "$cask" | xargs brew install --cask
  fi
}

# ============================================================================
# GNU Coreutils — Prefer GNU tools over BSD variants
# ============================================================================

# @description  Use GNU coreutils if installed via Homebrew.
#               GNU variants are more feature-rich and cross-platform consistent.
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  local _gnu_dirs=(
    "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-tar/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/make/libexec/gnubin"
  )
  local _d
  for _d in "${_gnu_dirs[@]}"; do
    [[ -d "$_d" ]] && path=("$_d" $path)
  done
  unset _d _gnu_dirs
fi

# ============================================================================
# macOS System Aliases
# ============================================================================

# @description  Finder — Show/hide hidden files
alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# @description  Finder — Show/hide desktop icons
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"

# @description  Spotlight — Rebuild Spotlight index
alias spotlight-reindex="sudo mdutil -E /"

# @description  DNS cache flush
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && log_info 'DNS cache flushed'"

# @description  Screen lock
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias afk="pmset displaysleepnow"

# @description  Empty all trash
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# @description  System update
alias macupdate="softwareupdate -ia --verbose"

# @description  Quick Look preview from terminal
alias ql="qlmanage -p"

# @description  Volume control
alias mute="osascript -e 'set volume output muted true'"
alias unmute="osascript -e 'set volume output muted false'"

# @description  Airport / WiFi info
alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
alias wifi-scan="airport -s"
alias wifi-info="airport -I"

# ============================================================================
# macOS Functions
# ============================================================================

# @description  Open Finder in the current directory (or specified path)
# @param  $1    string  (optional) Path to open (default: current directory)
# @return       void
function o() {
  open "${1:-.}"
}

# @description  Show app bundle info
# @param  $1    string  Application name
# @return       void
function appinfo() {
  local app="${1:?Usage: appinfo <AppName>}"
  local app_path="/Applications/${app}.app"
  [[ -d "$app_path" ]] || app_path="/Applications/${app}"
  [[ -d "$app_path" ]] || { log_error "App not found: %s" "$app"; return 1; }

  defaults read "${app_path}/Contents/Info.plist" 2>/dev/null | head -30
}

# @description  Toggle macOS dark mode
# @return       void
function darkmode() {
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
  log_info "Dark mode toggled"
}

# @description  Notify via macOS notification center
# @param  $1    string  Title
# @param  $2    string  Message body
# @return       void
function notify() {
  local title="${1:?Usage: notify <title> <message>}"
  local message="${2:-}"
  osascript -e "display notification \"${message}\" with title \"${title}\""
}

# @description  Show macOS system information summary
# @return       void
function macinfo() {
  printf "\n   macOS System Info\n"
  printf "  ─────────────────────────────────\n"
  printf "  macOS:     %s\n" "$(sw_vers -productVersion)"
  printf "  Build:     %s\n" "$(sw_vers -buildVersion)"
  printf "  Chip:      %s\n" "$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo 'N/A')"
  printf "  Arch:      %s\n" "$(uname -m)"
  printf "  Memory:    %sGB\n" "$(( $(sysctl -n hw.memsize) / 1073741824 ))"
  printf "  Disk:      %s\n" "$(df -h / | awk 'NR==2{print $3 " / " $2 " (" $5 " used)"}')"
  printf "  Serial:    %s\n" "$(system_profiler SPHardwareDataType 2>/dev/null | awk '/Serial/ {print $NF}')"
  printf "  ─────────────────────────────────\n\n"
}

# @description  Manage macOS power settings
# @param  $1    string  Action: "status" | "caffeinate" | "sleep"
# @return       void
function power() {
  case "${1:-status}" in
    status)
      pmset -g batt
      ;;
    caffeinate|nosleep)
      log_info "Preventing sleep (Ctrl-C to stop)..."
      caffeinate -d -i -s
      ;;
    sleep)
      pmset sleepnow
      ;;
    *)
      log_error "Usage: power [status|caffeinate|sleep]"
      ;;
  esac
}

log_debug "macOS platform configured"
