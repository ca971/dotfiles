# ============================================================================
# Docker & Podman — aliases
# ============================================================================

alias dk="docker"
alias dkc="docker compose"
alias dkcu="docker compose up -d"
alias dkcd="docker compose down"
alias dkcl="docker compose logs -f"
alias dkcr="docker compose restart"
alias dkcb="docker compose build --no-cache"
alias dkcp="docker compose pull"
alias dkv="docker volume ls"
alias dkn="docker network ls"
alias dkprune="docker system prune -af --volumes"

export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_CONFIG="${XDG_CONFIG_HOME:-${HOME}/.config}/docker"
