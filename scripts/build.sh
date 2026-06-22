#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUTPUT_DIR="${REPO_ROOT}/.build/output"
OUTPUT_FILE="${OUTPUT_DIR}/build-status.json"
LOCAL_FALLBACK="${REPO_ROOT}/build-status.json"
REMOTE_URL=${BUILD_STATUS_URL:-""}
RETRIES=${BUILD_FETCH_RETRIES:-3}
CONNECT_TIMEOUT=${BUILD_CONNECT_TIMEOUT:-5}
MAX_TIME=${BUILD_FETCH_TIMEOUT:-20}

mkdir -p "${OUTPUT_DIR}"

fetch_remote() {
  if [[ -z "${REMOTE_URL}" ]]; then
    return 1
  fi

  local tmp_file
  tmp_file=$(mktemp)

  for attempt in $(seq 1 "${RETRIES}"); do
    if curl -fsSL --connect-timeout "${CONNECT_TIMEOUT}" --max-time "${MAX_TIME}" "${REMOTE_URL}" -o "${tmp_file}"; then
      if [[ -s "${tmp_file}" ]]; then
        mv "${tmp_file}" "${OUTPUT_FILE}"
        return 0
      fi
    fi
    sleep "${attempt}"
  done

  rm -f "${tmp_file}"
  return 1
}

if fetch_remote; then
  printf 'build-status source=remote output=%s\n' "${OUTPUT_FILE}"
  exit 0
fi

if [[ -f "${LOCAL_FALLBACK}" ]]; then
  cp "${LOCAL_FALLBACK}" "${OUTPUT_FILE}"
  printf 'build-status source=local-fallback output=%s\n' "${OUTPUT_FILE}"
  exit 0
fi

cat > "${OUTPUT_FILE}" <<'JSON'
{"status":"degraded","source":"generated-fallback"}
JSON
printf 'build-status source=generated-fallback output=%s\n' "${OUTPUT_FILE}"
