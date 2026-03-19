#!/usr/bin/env zsh
# ============================================================================
# @file        functions/network.zsh
# @description Network utility functions for connection testing, port
#              scanning, DNS lookups, HTTP debugging, and network
#              information display.
# @repository  https://github.com/ca971/zsh-config.git
# @author      ca971
# @license     MIT
# @created     2025-07-14
# @version     1.0.0
#
# @depends     lib/logging.zsh
# ============================================================================

# ── Guard ────────────────────────────────────────────────────────────────────
[[ -n "${_ZSH_FUNCTIONS_NETWORK_LOADED:-}" ]] && return 0
readonly _ZSH_FUNCTIONS_NETWORK_LOADED=1

# ============================================================================
# IP Information
# ============================================================================

# @description  Show public IP address with geolocation info
# @return       void
function myip() {
  printf "\n  🌐 IP Information\n"
  printf "  ─────────────────────────────────\n"

  local public_ip
  public_ip=$(curl -s --max-time 5 https://ifconfig.me 2>/dev/null || \
              curl -s --max-time 5 https://api.ipify.org 2>/dev/null || \
              echo "unavailable")
  printf "  Public:  %s\n" "$public_ip"

  # -- Local IPs
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    local local_ip
    local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "N/A")
    printf "  Local:   %s\n" "$local_ip"
  else
    local local_ip
    local_ip=$(ip -4 addr show scope global 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || \
               hostname -I 2>/dev/null | awk '{print $1}' || echo "N/A")
    printf "  Local:   %s\n" "$local_ip"
  fi

  # -- Geolocation (optional)
  if [[ "$public_ip" != "unavailable" ]]; then
    local geo
    geo=$(curl -s --max-time 5 "https://ipinfo.io/${public_ip}/json" 2>/dev/null)
    if [[ -n "$geo" ]]; then
      local city country org
      city=$(echo "$geo" | python3 -c "import sys,json; print(json.load(sys.stdin).get('city',''))" 2>/dev/null)
      country=$(echo "$geo" | python3 -c "import sys,json; print(json.load(sys.stdin).get('country',''))" 2>/dev/null)
      org=$(echo "$geo" | python3 -c "import sys,json; print(json.load(sys.stdin).get('org',''))" 2>/dev/null)
      [[ -n "$city" ]] && printf "  Location: %s, %s\n" "$city" "$country"
      [[ -n "$org" ]] && printf "  ISP:     %s\n" "$org"
    fi
  fi

  printf "  ─────────────────────────────────\n\n"
}

# ============================================================================
# Connection Testing
# ============================================================================

# @description  Test TCP connectivity to a host and port
# @param  $1    string   Hostname or IP
# @param  $2    integer  Port number
# @param  $3    integer  (optional) Timeout in seconds (default: 5)
# @return       0 if reachable, 1 if not
function port_check() {
  local host="${1:?Usage: port_check <host> <port> [timeout]}"
  local port="${2:?Usage: port_check <host> <port> [timeout]}"
  local timeout="${3:-5}"

  if (echo >/dev/tcp/"$host"/"$port") 2>/dev/null; then
    printf "  ✅ %s:%s is reachable\n" "$host" "$port"
    return 0
  else
    printf "  ❌ %s:%s is unreachable\n" "$host" "$port"
    return 1
  fi
}

# @description  Check connectivity to common services
# @return       void
function net_check() {
  printf "\n  🌐 Connectivity Check\n"
  printf "  ─────────────────────────────────\n"

  local -A services=(
    [DNS]="8.8.8.8:53"
    [HTTP]="google.com:80"
    [HTTPS]="google.com:443"
    [GitHub]="github.com:443"
  )

  local name addr host port
  for name in DNS HTTP HTTPS GitHub; do
    addr="${services[$name]}"
    host="${addr%%:*}"
    port="${addr##*:}"
    printf "  %-10s " "$name"
    if (echo >/dev/tcp/"$host"/"$port") 2>/dev/null; then
      printf "✅ OK\n"
    else
      printf "❌ FAIL\n"
    fi
  done

  printf "  ─────────────────────────────────\n\n"
}

# ============================================================================
# DNS Utilities
# ============================================================================

# @description  Show DNS records for a domain
# @param  $1    string  Domain name
# @param  $2    string  (optional) Record type (default: all common types)
# @return       void
function dns() {
  local domain="${1:?Usage: dns <domain> [record-type]}"
  local rtype="${2:-}"

  if [[ -n "$rtype" ]]; then
    dig +short "$domain" "$rtype" 2>/dev/null || \
      nslookup -type="$rtype" "$domain" 2>/dev/null
  else
    printf "\n  🔍 DNS Records: %s\n\n" "$domain"
    local type
    for type in A AAAA CNAME MX NS TXT; do
      local result
      result=$(dig +short "$domain" "$type" 2>/dev/null)
      if [[ -n "$result" ]]; then
        printf "  %-6s %s\n" "$type" "$result"
      fi
    done
    printf "\n"
  fi
}

# ============================================================================
# HTTP Utilities
# ============================================================================

# @description  Show HTTP response headers for a URL
# @param  $1    string  URL
# @return       void
function http_headers() {
  local url="${1:?Usage: http_headers <url>}"
  curl -sSI -o /dev/null -w "%{http_code}" "$url" 2>/dev/null
  echo
  curl -sSI "$url" 2>/dev/null | \
    if has "bat"; then bat --language http --plain; else cat; fi
}

# @description  Measure HTTP response time for a URL
# @param  $1    string  URL
# @return       void
function http_time() {
  local url="${1:?Usage: http_time <url>}"

  printf "\n  ⏱  HTTP Timing: %s\n" "$url"
  printf "  ─────────────────────────────────\n"

  curl -sSo /dev/null -w "\
  DNS:       %{time_namelookup}s\n\
  Connect:   %{time_connect}s\n\
  TLS:       %{time_appconnect}s\n\
  Start:     %{time_starttransfer}s\n\
  Total:     %{time_total}s\n\
  Status:    %{http_code}\n\
  Size:      %{size_download} bytes\n" "$url"

  printf "  ─────────────────────────────────\n\n"
}

# ============================================================================
# Port & Process
# ============================================================================

# @description  Show which process is listening on a given port
# @param  $1    integer  Port number
# @return       void
function whois_port() {
  local port="${1:?Usage: whois_port <port>}"

  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    lsof -i ":${port}" -P -n 2>/dev/null | head -10
  else
    ss -tulpn 2>/dev/null | grep ":${port}" || \
      netstat -tulpn 2>/dev/null | grep ":${port}"
  fi
}

# @description  List all listening ports with associated processes
# @return       void
function listening() {
  printf "\n  🔌 Listening Ports\n\n"
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | \
      awk 'NR==1 || !/^$/{printf "  %-15s %-8s %s\n", $1, $9, $2}'
  else
    ss -tulpn 2>/dev/null | awk 'NR==1 || /LISTEN/{print "  "$0}'
  fi
  printf "\n"
}

# @description  Show active network connections summary
# @return       void
function net_connections() {
  printf "\n  🔗 Active Connections\n\n"
  if [[ "$ZSH_PLATFORM" == "darwin" ]]; then
    netstat -an 2>/dev/null | awk '/^tcp/{states[$6]++} END {for (s in states) printf "  %-15s %d\n", s, states[s]}' | sort
  else
    ss -s 2>/dev/null
  fi
  printf "\n"
}

log_debug "Network functions loaded"
