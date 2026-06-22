#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS_FILE="${BUILD_STATUS_FILE:-$ROOT_DIR/build-status.json}"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/.build}"
OUTPUT_FILE="${BUILD_OUTPUT_FILE:-$BUILD_DIR/dependency-schema.json}"
TMP_OUTPUT="$OUTPUT_FILE.tmp"
CURL_BIN="${CURL_BIN:-curl}"
FALLBACK_IP="${BUILD_FALLBACK_IP:-66.241.125.128}"

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
    raise SystemExit("Missing $schema in build status file")
print(schema)
PY
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

echo "Dependency fetch failed across all transports" >&2
rm -f "$TMP_OUTPUT"
exit 1
