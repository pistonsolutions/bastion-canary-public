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

  if ! command -v curl >/dev/null 2>&1; then
    return 1
  fi

  curl --fail --silent --show-error --location --max-time 10 "${url}" -o "${TMP_FILE}"
}

copy_source() {
  local source="$1"
  [ -f "${source}" ] && cp "${source}" "${TMP_FILE}"
}

if [ -n "${BUILD_STATUS_URL:-}" ] && fetch_remote "${BUILD_STATUS_URL}"; then
  :
elif copy_source "${CACHE_FILE}"; then
  :
elif copy_source "${SOURCE_FILE}"; then
  :
else
  printf '{\n  "status": "unknown"\n}\n' > "${TMP_FILE}"
fi

mv "${TMP_FILE}" "${OUTPUT_FILE}"
cp "${OUTPUT_FILE}" "${CACHE_FILE}"
printf 'Build status written to %s\n' "${OUTPUT_FILE}"
