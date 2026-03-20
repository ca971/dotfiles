#!/usr/bin/env zsh
# ============================================================================
# @file        tools/docker.zsh
# @description Docker/Podman — runtime detection + functions.
# @version     4.0.0
# ============================================================================

[[ -n "${_ZSH_TOOLS_DOCKER_LOADED:-}" ]] && return 0
readonly _ZSH_TOOLS_DOCKER_LOADED=1

has_any "docker" "podman" || return 0
log_debug "Configuring docker"

typeset -g CONTAINER_RUNTIME=""
has "podman" && ! has "docker" && { CONTAINER_RUNTIME="podman"; alias docker="podman"; } || CONTAINER_RUNTIME="docker"

typeset -g COMPOSE_CMD=""
${CONTAINER_RUNTIME} compose version &>/dev/null 2>&1 && COMPOSE_CMD="${CONTAINER_RUNTIME} compose" || has "docker-compose" && COMPOSE_CMD="docker-compose"


function dps()      { ${CONTAINER_RUNTIME} ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}' "$@"; }
function dpsa()     { ${CONTAINER_RUNTIME} ps -a --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}' "$@"; }
function dexec()    { local c; has "fzf" && c=$(${CONTAINER_RUNTIME} ps --format '{{.Names}}' | fzf --header='Container') || { dps; printf "Name: "; read -r c; }; [[ -n "$c" ]] && ${CONTAINER_RUNTIME} exec -it "$c" "${1:-/bin/sh}"; }
function dlogs()    { local c="${1:-}"; [[ -z "$c" ]] && has "fzf" && c=$(${CONTAINER_RUNTIME} ps --format '{{.Names}}' | fzf --header='Logs'); [[ -n "$c" ]] && ${CONTAINER_RUNTIME} logs -f --tail=100 "$c"; }
function dstopall() { local ids=$(${CONTAINER_RUNTIME} ps -q); [[ -n "$ids" ]] && echo "$ids" | xargs ${CONTAINER_RUNTIME} stop || log_info "No running containers"; }
function dclean()   { printf "Prune everything? [y/N]: "; read -rk1 c; echo; [[ "${c:l}" == "y" ]] && ${CONTAINER_RUNTIME} system prune -af --volumes; }
function dstats()   { ${CONTAINER_RUNTIME} stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}'; }
function drun()     { ${CONTAINER_RUNTIME} run --rm -it "$@"; }

if [[ -n "$COMPOSE_CMD" ]]; then
  function dcup()      { eval "${COMPOSE_CMD} up -d --build $*"; }
  function dcdown()    { eval "${COMPOSE_CMD} down $*"; }
  function dclogs()    { eval "${COMPOSE_CMD} logs -f $*"; }
  function dcrestart() { eval "${COMPOSE_CMD} restart $*"; }
  function dcps()      { eval "${COMPOSE_CMD} ps $*"; }
fi

function docker-info() { printf "\n  🐳 Docker\n  ─────────────────\n  Runtime: %s\n  Compose: %s\n  Running: %s\n  ─────────────────\n\n" "$CONTAINER_RUNTIME" "${COMPOSE_CMD:-none}" "$(${CONTAINER_RUNTIME} ps -q 2>/dev/null | wc -l | tr -d ' ')"; }

log_debug "docker configured"
