#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/.build/output"
OUTPUT_FILE="${OUTPUT_DIR}/build-status.json"
SOURCE_FILE="${ROOT_DIR}/build-status.json"
CACHE_FILE="${ROOT_DIR}/.build/cache/build-status.json"
TMP_FILE="${OUTPUT_FILE}.tmp"

mkdir -p "${OUTPUT_DIR}" "${ROOT_DIR}/.build/cache"

fetch_remote() {
  local url="$1"
  local curl_exit_code=0

  if ! command -v curl >/dev/null 2>&1; then
    printf 'curl is unavailable; skipping remote status fetch\n' >&2
    return 1
  fi

  curl --fail --silent --show-error --location --max-time 10 "${url}" -o "${TMP_FILE}" || {
    curl_exit_code=$?
    printf 'remote status fetch failed (curl exit %s); using fallback\n' "${curl_exit_code}" >&2
    return 1
  }
}

copy_source() {
  local source="$1"
  if [ -f "${source}" ]; then
    cp "${source}" "${TMP_FILE}"
    return 0
  fi

  printf 'fallback source missing: %s\n' "${source}" >&2
  return 1
}

if [ -n "${BUILD_STATUS_URL:-}" ] && fetch_remote "${BUILD_STATUS_URL}"; then
  :
elif copy_source "${CACHE_FILE}"; then
  :
elif copy_source "${SOURCE_FILE}"; then
  :
else
  cat > "${TMP_FILE}" <<'JSON'
{
  "status": "unknown"
}
JSON
fi

mv "${TMP_FILE}" "${OUTPUT_FILE}"
cp "${OUTPUT_FILE}" "${CACHE_FILE}"
printf 'Build status written to %s\n' "${OUTPUT_FILE}"
