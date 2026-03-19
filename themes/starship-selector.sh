#!/bin/sh
# ============================================================================
# @file        themes/starship-selector.sh
# @description Universal Starship theme selector — works with ANY shell.
#              Detects runtime context (SSH, Docker, Proxmox, K8s, VPS)
#              and sets STARSHIP_CONFIG to the appropriate theme file.
#
#              Sourced by: .zshrc, .bashrc, config.fish, config.nu
#
# @repository  https://github.com/ca971/dotfiles.git
# @author      ca971
# @license     MIT
# @created     2025-07-15
# @version     1.0.0
# ============================================================================

# ── Resolve DOTFILES_DIR ────────────────────────────────────────────────────
DOTFILES_DIR="${DOTFILES_DIR:-${HOME}/dotfiles}"
_THEMES_DIR="${DOTFILES_DIR}/themes"

# ── Default theme ────────────────────────────────────────────────────────────
_STARSHIP_THEME="powerline"

# ============================================================================
# Detection Logic (POSIX sh compatible — no bashisms)
# ============================================================================

# ── Priority 1: Manual override ─────────────────────────────────────────────
if [ -n "${STARSHIP_THEME:-}" ]; then
    _STARSHIP_THEME="${STARSHIP_THEME}"

# ── Priority 2: Proxmox / Kubernetes node / VPS ─────────────────────────────
elif [ -f "/etc/pve/.version" ] || [ -d "/etc/pve" ]; then
    _STARSHIP_THEME="nerd"

elif [ -f "/var/run/secrets/kubernetes.io/serviceaccount/token" ]; then
    _STARSHIP_THEME="nerd"

elif [ -n "${PROXMOX_HOST:-}" ] || [ -n "${K8S_NODE:-}" ]; then
    _STARSHIP_THEME="nerd"

elif [ -f "/sys/class/dmi/id/product_name" ] \
    && grep -qiE 'virtual|vmware|kvm|xen|qemu|hyper-v|bochs' /sys/class/dmi/id/product_name 2> /dev/null; then
    _STARSHIP_THEME="nerd"

elif command -v systemd-detect-virt > /dev/null 2>&1; then
    _virt="$(systemd-detect-virt 2> /dev/null)"
    if [ "$_virt" != "none" ] && [ -n "$_virt" ]; then
        _STARSHIP_THEME="nerd"
    fi
    unset _virt

# ── Priority 3: SSH / Docker / Container / OPNsense ─────────────────────────
elif [ -n "${SSH_CONNECTION:-}" ] || [ -n "${SSH_CLIENT:-}" ] || [ -n "${SSH_TTY:-}" ]; then
    _STARSHIP_THEME="minimal"

elif [ -f "/.dockerenv" ] || [ -f "/run/.containerenv" ]; then
    _STARSHIP_THEME="minimal"

elif [ -f "/proc/1/cgroup" ] && grep -qE 'docker|lxc|containerd|podman' /proc/1/cgroup 2> /dev/null; then
    _STARSHIP_THEME="minimal"

elif [ -f "/conf/config.xml" ] && [ -d "/usr/local/etc/rc.d" ]; then
    _STARSHIP_THEME="minimal"

elif [ "$(uname -s)" = "FreeBSD" ]; then
    _STARSHIP_THEME="minimal"
fi

# ============================================================================
# Apply Theme
# ============================================================================

_THEME_FILE="${_THEMES_DIR}/starship-${_STARSHIP_THEME}.toml"

if [ -f "$_THEME_FILE" ]; then
    STARSHIP_CONFIG="$_THEME_FILE"
else
    # Fallback
    STARSHIP_CONFIG="${_THEMES_DIR}/starship-powerline.toml"
fi

export STARSHIP_CONFIG
export STARSHIP_THEME="${_STARSHIP_THEME}"
export STARSHIP_CACHE="${XDG_CACHE_HOME:-${HOME}/.cache}/starship"

# ── Cleanup ──────────────────────────────────────────────────────────────────
unset _STARSHIP_THEME _THEME_FILE _THEMES_DIR

# ── Add dotfiles/bin to PATH ─────────────────────────────────────────────────
case ":${PATH}:" in
    *":${DOTFILES_DIR}/bin:"*) ;;
    *) export PATH="${DOTFILES_DIR}/bin:${PATH}" ;;
esac
