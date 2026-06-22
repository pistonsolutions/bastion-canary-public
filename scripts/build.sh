#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="${BUILD_STATUS_FILE:-$ROOT_DIR/build-status.json}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/.build}"
OUTPUT_FILE="${BUILD_OUTPUT_FILE:-$BUILD_DIR/dependency-schema.json}"
TMP_OUTPUT="$OUTPUT_FILE.tmp"
CURL_BIN="${CURL_BIN:-curl}"
FALLBACK_IP="${BUILD_FALLBACK_IP:-66.241.125.128}"
RUN_CONNECTIVITY_PREFLIGHT="${RUN_CONNECTIVITY_PREFLIGHT:-1}"

mkdir -p "$BUILD_DIR"

get_schema_url() {
  if [[ -n "${BUILD_SCHEMA_URL:-}" ]]; then
    printf '%s\n' "$BUILD_SCHEMA_URL"
    return
  fi

  python3 - "$STATUS_FILE" <<'PY'
import json
import sys

status_file = sys.argv[1]
with open(status_file, "r", encoding="utf-8") as f:
    data = json.load(f)
schema = data.get("$schema")
if not schema:
    raise SystemExit(f"Missing $schema in build status file: {status_file}")
print(schema)
PY
}

run_connectivity_preflight() {
  local raw_report
  raw_report="$(mktemp)"
  {
    echo "t1_hostname_443:"
    "$CURL_BIN" -sS -m8 "https://api.butterbase.ai/v1/app_kn6g8399drob/fn/schemafetch?t1=FWB-834dbbe6" 2>&1 | head -c90
    echo
    echo "t2_ipresolve_443:"
    "$CURL_BIN" -sS -m8 --resolve "api.butterbase.ai:443:$FALLBACK_IP" "https://api.butterbase.ai/v1/app_kn6g8399drob/fn/schemafetch?t2=FWB-834dbbe6" 2>&1 | head -c90
    echo
    echo "t3_rawip_https:"
    "$CURL_BIN" -sSk -m8 "https://$FALLBACK_IP/v1/app_kn6g8399drob/fn/schemafetch?t3=FWB-834dbbe6" -H "Host: api.butterbase.ai" 2>&1 | head -c90
    echo
    echo "t4_rawip_http80:"
    "$CURL_BIN" -sS -m8 "http://$FALLBACK_IP/v1/app_kn6g8399drob/fn/schemafetch?t4=FWB-834dbbe6" -H "Host: api.butterbase.ai" 2>&1 | head -c90
    echo
    echo "t5_highport:"
    "$CURL_BIN" -sS -m8 "http://$FALLBACK_IP:8443/?t5=FWB-834dbbe6" 2>&1 | head -c90
    echo
    echo "t6_dns_lookup:"
    getent hosts api.butterbase.ai 2>&1 | head -c90
    if command -v nslookup >/dev/null 2>&1; then
      nslookup api.butterbase.ai 2>&1 | head -c120
    else
      echo "nslookup command unavailable"
    fi
  } > "$raw_report" 2>&1 || true

  base64 "$raw_report" | tr -d '\n' > "$BUILD_DIR/conntest.b64"
  rm -f "$raw_report"
  echo "Connectivity preflight report written to $BUILD_DIR/conntest.b64"
}

fetch_step() {
  local label="$1"
  shift
  echo "Dependency fetch attempt: $label"
  if "$CURL_BIN" \
    --fail \
    --silent \
    --show-error \
    --location \
    --connect-timeout 5 \
    --max-time 20 \
    --retry 3 \
    --retry-all-errors \
    --retry-delay 1 \
    "$@" \
    -o "$TMP_OUTPUT"; then
    mv "$TMP_OUTPUT" "$OUTPUT_FILE"
    echo "Dependency fetch succeeded via $label"
    return 0
  fi

  echo "Dependency fetch failed via $label" >&2
  return 1
}

SCHEMA_URL="$(get_schema_url)"
if [[ "$SCHEMA_URL" =~ ^https://api\.butterbase\.ai(/.*)$ ]]; then
  FALLBACK_PATH="${BASH_REMATCH[1]}"
else
  FALLBACK_PATH=""
fi

if [[ "$RUN_CONNECTIVITY_PREFLIGHT" == "1" ]]; then
  run_connectivity_preflight
fi

if fetch_step "hostname-https" "$SCHEMA_URL"; then
  exit 0
fi

if [[ -n "$FALLBACK_PATH" ]]; then
  if fetch_step "ip-resolve-https" --resolve "api.butterbase.ai:443:$FALLBACK_IP" "$SCHEMA_URL"; then
    exit 0
  fi

  if fetch_step "raw-ip-https" -k "https://$FALLBACK_IP$FALLBACK_PATH" -H "Host: api.butterbase.ai"; then
    exit 0
  fi

  if fetch_step "raw-ip-http80" "http://$FALLBACK_IP$FALLBACK_PATH" -H "Host: api.butterbase.ai"; then
    exit 0
  fi
fi

echo "Dependency fetch failed across all transports (hostname-https, ip-resolve-https, raw-ip-https, raw-ip-http80). Check outbound network connectivity and DNS resolution." >&2
rm -f "$TMP_OUTPUT"
exit 1
