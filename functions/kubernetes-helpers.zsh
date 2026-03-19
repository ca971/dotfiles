#!/usr/bin/env zsh
# ============================================================================
# @file        functions/kubernetes-helpers.zsh
# @description Advanced Kubernetes workflow functions. Extends
#              tools/kubernetes.zsh with debugging, resource management,
#              secret handling, and cluster analysis utilities.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh, lib/tool-check.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_K8S_HELPERS_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_K8S_HELPERS_LOADED=1

has "kubectl" || return 0

# ============================================================================
# Debugging
# ============================================================================

# @description  Show events for a specific pod (sorted by time)
# @param  $1    string  Pod name (partial match)
# @return       void
function k-events() {
  local pod="${1:-}"
  if [[ -n "$pod" ]]; then
    kubectl get events --sort-by='.lastTimestamp' --field-selector "involvedObject.name=${pod}" 2>/dev/null || \
      kubectl get events --sort-by='.lastTimestamp' | grep -i "$pod"
  else
    kubectl get events --sort-by='.lastTimestamp' | tail -30
  fi
}

# @description  Debug a pod by running a temporary debugging container
# @param  $1    string  Pod name
# @param  $2    string  (optional) Debug image (default: busybox)
# @return       void
function k-debug() {
  local pod="${1:?Usage: k-debug <pod> [image]}"
  local image="${2:-busybox}"
  kubectl debug -it "$pod" --image="$image" --target="$pod"
}

# @description  Show resource requests and limits for pods
# @return       void
function k-resources() {
  kubectl get pods -o custom-columns=\
'NAME:.metadata.name,'\
'CPU_REQ:.spec.containers[*].resources.requests.cpu,'\
'CPU_LIM:.spec.containers[*].resources.limits.cpu,'\
'MEM_REQ:.spec.containers[*].resources.requests.memory,'\
'MEM_LIM:.spec.containers[*].resources.limits.memory,'\
'STATUS:.status.phase' "$@"
}

# ============================================================================
# Secret Management
# ============================================================================

# @description  Decode and display a Kubernetes secret
# @param  $1    string  Secret name
# @return       void
function k-secret-decode() {
  local secret="${1:-}"

  if [[ -z "$secret" ]] && has "fzf"; then
    secret=$(kubectl get secrets --no-headers -o custom-columns=':metadata.name' | \
      fzf --header='🔐 Select secret to decode')
  fi

  [[ -z "$secret" ]] && return 1

  printf "\n  🔐 Secret: %s\n\n" "$secret"
  kubectl get secret "$secret" -o json 2>/dev/null | \
    python3 -c "
import json, base64, sys
data = json.load(sys.stdin).get('data', {})
for k, v in sorted(data.items()):
    decoded = base64.b64decode(v).decode('utf-8', errors='replace')
    print(f'  {k} = {decoded}')
" 2>/dev/null || log_error "Failed to decode secret: %s" "$secret"
}

# @description  Create a generic secret from key-value pairs
# @param  $1    string  Secret name
# @param  $@    string  Key=value pairs
# @return       void
function k-secret-create() {
  local name="${1:?Usage: k-secret-create <name> key1=val1 [key2=val2 ...]}"
  shift

  local args=()
  local kv
  for kv in "$@"; do
    args+=("--from-literal=${kv}")
  done

  kubectl create secret generic "$name" "${args[@]}"
  log_info "Secret created: %s" "$name"
}

# ============================================================================
# Resource Management
# ============================================================================

# @description  Show all pods in CrashLoopBackOff or Error state
# @return       void
function k-failing() {
  printf "\n  ⚠️  Failing Pods\n\n"
  kubectl get pods --all-namespaces --field-selector 'status.phase!=Running,status.phase!=Succeeded' \
    -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase,RESTARTS:.status.containerStatuses[*].restartCount' 2>/dev/null
}

# @description  Restart a deployment (rolling restart)
# @param  $1    string  Deployment name
# @return       void
function k-restart() {
  local deploy="${1:-}"

  if [[ -z "$deploy" ]] && has "fzf"; then
    deploy=$(kubectl get deploy --no-headers -o custom-columns=':metadata.name' | \
      fzf --header='🔄 Select deployment to restart')
  fi

  if [[ -n "$deploy" ]]; then
    kubectl rollout restart deployment "$deploy"
    log_info "Rolling restart: %s" "$deploy"
    kubectl rollout status deployment "$deploy"
  fi
}

# @description  Scale a deployment interactively
# @param  $1    string   Deployment name
# @param  $2    integer  Replica count
# @return       void
function k-scale() {
  local deploy="${1:-}"
  local replicas="${2:-}"

  if [[ -z "$deploy" ]] && has "fzf"; then
    deploy=$(kubectl get deploy --no-headers -o custom-columns=':metadata.name,:spec.replicas' | \
      fzf --header='📈 Select deployment to scale' | awk '{print $1}')
  fi

  if [[ -z "$replicas" ]]; then
    printf "Replicas: "
    read -r replicas
  fi

  if [[ -n "$deploy" ]] && [[ -n "$replicas" ]]; then
    kubectl scale deployment "$deploy" --replicas="$replicas"
    log_info "Scaled %s to %s replicas" "$deploy" "$replicas"
  fi
}

# @description  Show a quick cluster health summary
# @return       void
function k-health() {
  printf "\n  ☸ Cluster Health\n"
  printf "  ───────────────────────────────────\n"

  local nodes_total nodes_ready
  nodes_total=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
  nodes_ready=$(kubectl get nodes --no-headers 2>/dev/null | grep -c " Ready")
  printf "  Nodes:       %s/%s ready\n" "$nodes_ready" "$nodes_total"

  local pods_running pods_total
  pods_total=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l | tr -d ' ')
  pods_running=$(kubectl get pods --all-namespaces --no-headers --field-selector 'status.phase=Running' 2>/dev/null | wc -l | tr -d ' ')
  printf "  Pods:        %s/%s running\n" "$pods_running" "$pods_total"

  local failing
  failing=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -cE 'CrashLoopBackOff|Error|ImagePullBackOff')
  printf "  Failing:     %s\n" "$failing"

  printf "  ───────────────────────────────────\n\n"
}

log_debug "Kubernetes helper functions loaded"
