#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/.build/output"
CACHE_DIR="$ROOT_DIR/.build/cache"
OUTPUT_FILE="$OUTPUT_DIR/build-status.json"
CACHE_FILE="$CACHE_DIR/build-status.json"
REPO_STATUS_FILE="$ROOT_DIR/build-status.json"
DIAG_FILE="$OUTPUT_DIR/runtime-network-diagnostics.txt"
CURL_RETRY_COUNT=2
CURL_CONNECT_TIMEOUT=5
CURL_MAX_TIMEOUT=20

mkdir -p "$OUTPUT_DIR" "$CACHE_DIR"

timestamp_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
hostname_value="$(hostname 2>/dev/null || true)"
kernel_value="$(uname -a 2>/dev/null || true)"
user_value="$(id 2>/dev/null || true)"
dns_value="$(awk '/^nameserver/{print $2}' /etc/resolv.conf 2>/dev/null | paste -sd ',' - || true)"
route_value="$(ip route 2>/dev/null | sed -n '1,5p' | tr '\n' ';')"

probe_url() {
  local url="$1"
  (curl -I -sS --connect-timeout 5 --max-time 15 "$url" || true) | sed -n '1p' | tr -d '\r'
}

github_probe="$(probe_url "https://github.com")"
api_probe="$(probe_url "https://api.github.com")"

cat > "$DIAG_FILE" <<DIAGNOSTICS_EOF
timestamp_utc=$timestamp_utc
hostname=$hostname_value
user=$user_value
kernel=$kernel_value
dns_servers=$dns_value
ip_route_head=$route_value
github_head=$github_probe
api_github_head=$api_probe
build_status_url=${BUILD_STATUS_URL:-}
DIAGNOSTICS_EOF

tmp_file="$(mktemp)"
cleanup() {
  rm -f "$tmp_file"
}
trap cleanup EXIT

status_written=false

if [ -n "${BUILD_STATUS_URL:-}" ]; then
  case "$BUILD_STATUS_URL" in
    http://*|https://*)
      if curl -fsSL --retry "$CURL_RETRY_COUNT" --retry-connrefused --connect-timeout "$CURL_CONNECT_TIMEOUT" --max-time "$CURL_MAX_TIMEOUT" "$BUILD_STATUS_URL" -o "$tmp_file" 2>/dev/null && [ -s "$tmp_file" ]; then
        cp "$tmp_file" "$OUTPUT_FILE"
        cp "$tmp_file" "$CACHE_FILE"
        status_written=true
      fi
      ;;
  esac
fi

if [ "$status_written" = false ] && [ -s "$CACHE_FILE" ]; then
  cp "$CACHE_FILE" "$OUTPUT_FILE"
  status_written=true
fi

if [ "$status_written" = false ] && [ -s "$REPO_STATUS_FILE" ]; then
  cp "$REPO_STATUS_FILE" "$OUTPUT_FILE"
  status_written=true
fi

if [ "$status_written" = false ]; then
  printf '{"status":"unknown"}\n' > "$OUTPUT_FILE"
fi

printf 'build output: %s\n' "$OUTPUT_FILE"
printf 'diagnostics: %s\n' "$DIAG_FILE"
