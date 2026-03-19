#!/usr/bin/env zsh
# ============================================================================
# @file        functions/docker-helpers.zsh
# @description Advanced Docker workflow functions for container inspection,
#              image management, volume operations, and multi-container
#              orchestration. Extends the base tools/docker.zsh configuration.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_DOCKER_HELPERS_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_DOCKER_HELPERS_LOADED=1

has_any "docker" "podman" || return 0

# @description  Resolved container runtime
local _rt="${CONTAINER_RUNTIME:-docker}"

# ============================================================================
# Container Inspection
# ============================================================================

# @description  Show detailed information about a container (formatted JSON)
# @param  $1    string  Container name or ID
# @return       void
function docker-inspect() {
  local container="${1:-}"

  if [[ -z "$container" ]] && has "fzf"; then
    container=$($_rt ps -a --format '{{.Names}}\t{{.Status}}' | \
      fzf --header='🔍 Select container to inspect' | awk '{print $1}')
  fi

  [[ -z "$container" ]] && return 1

  $_rt inspect "$container" | \
    if has "bat"; then
      bat --language json --style plain
    elif has "python3"; then
      python3 -m json.tool
    else
      cat
    fi
}

# @description  Show environment variables of a running container
# @param  $1    string  Container name or ID
# @return       void
function docker-env() {
  local container="${1:-}"

  if [[ -z "$container" ]] && has "fzf"; then
    container=$($_rt ps --format '{{.Names}}' | \
      fzf --header='🔧 Select container')
  fi

  [[ -z "$container" ]] && return 1

  $_rt inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$container" | sort
}

# @description  Show the IP address of a container
# @param  $1    string  Container name or ID
# @return       IP address (printed to stdout)
function docker-ip() {
  local container="${1:?Usage: docker-ip <container>}"
  $_rt inspect --format '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container"
}

# @description  Show the mapped ports of a container
# @param  $1    string  Container name or ID
# @return       void
function docker-ports() {
  local container="${1:?Usage: docker-ports <container>}"
  $_rt port "$container"
}

# ============================================================================
# Image Management
# ============================================================================

# @description  Show image layer history (useful for debugging image size)
# @param  $1    string  Image name
# @return       void
function docker-layers() {
  local image="${1:?Usage: docker-layers <image>}"
  $_rt history --no-trunc --format "table {{.Size}}\t{{.CreatedBy}}" "$image"
}

# @description  Remove all dangling (untagged) images
# @return       void
function docker-rmi-dangling() {
  local images
  images=$($_rt images -q --filter "dangling=true")
  if [[ -n "$images" ]]; then
    echo "$images" | xargs $_rt rmi
    log_info "Dangling images removed"
  else
    log_info "No dangling images"
  fi
}

# @description  Show total disk usage by Docker
# @return       void
function docker-disk() {
  $_rt system df -v
}

# ============================================================================
# Volume Management
# ============================================================================

# @description  List orphaned volumes (not attached to any container)
# @return       void
function docker-orphan-volumes() {
  $_rt volume ls --filter "dangling=true" --format "table {{.Name}}\t{{.Driver}}\t{{.Labels}}"
}

# @description  Remove all orphaned volumes
# @return       void
function docker-clean-volumes() {
  if confirm "Remove all orphaned Docker volumes?"; then
    $_rt volume prune -f
    log_info "Orphaned volumes removed"
  fi
}

# ============================================================================
# Compose Helpers
# ============================================================================

# @description  Show docker-compose service dependency tree
# @return       void
function dc-deps() {
  if [[ ! -f "docker-compose.yml" ]] && [[ ! -f "docker-compose.yaml" ]] && [[ ! -f "compose.yml" ]] && [[ ! -f "compose.yaml" ]]; then
    log_error "No compose file found in current directory"
    return 1
  fi

  ${COMPOSE_CMD:-$_rt compose} config --services 2>/dev/null | sort
}

# @description  Run a one-off command in a compose service
# @param  $1    string  Service name
# @param  $@    Command and arguments
# @return       void
function dc-run() {
  local service="${1:?Usage: dc-run <service> <command>}"
  shift
  ${COMPOSE_CMD:-$_rt compose} run --rm "$service" "$@"
}

# @description  Tail logs for a specific compose service with follow and timestamps
# @param  $1    string  Service name
# @return       void
function dc-log() {
  local service="${1:-}"

  if [[ -z "$service" ]] && has "fzf"; then
    service=$(${COMPOSE_CMD:-$_rt compose} config --services 2>/dev/null | \
      fzf --header='📋 Select service for logs')
  fi

  [[ -n "$service" ]] && ${COMPOSE_CMD:-$_rt compose} logs -f --timestamps "$service"
}

log_debug "Docker helper functions loaded"
