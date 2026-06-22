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
MAX_BACKOFF=${BUILD_MAX_BACKOFF:-4}

mkdir -p "${OUTPUT_DIR}"

if ! command -v python >/dev/null 2>&1; then
  echo "python is required for JSON validation" >&2
  exit 1
fi

fetch_remote() {
  if [[ -z "${REMOTE_URL}" ]]; then
    return 1
  fi

  local tmp_file
  local sleep_seconds
  tmp_file=$(mktemp)

  for attempt in $(seq 1 "${RETRIES}"); do
    if curl -fsSL --connect-timeout "${CONNECT_TIMEOUT}" --max-time "${MAX_TIME}" "${REMOTE_URL}" -o "${tmp_file}"; then
      if [[ ! -s "${tmp_file}" ]]; then
        echo "warning: empty response from ${REMOTE_URL} (attempt ${attempt}/${RETRIES})" >&2
      elif ! python -m json.tool "${tmp_file}" >/dev/null 2>&1; then
        echo "warning: invalid JSON from ${REMOTE_URL} (attempt ${attempt}/${RETRIES})" >&2
      else
        mv "${tmp_file}" "${OUTPUT_FILE}"
        return 0
      fi
    fi

    if (( attempt < RETRIES )); then
      sleep_seconds=1
      for _ in $(seq 1 $((attempt - 1))); do
        sleep_seconds=$((sleep_seconds * 2))
        if (( sleep_seconds >= MAX_BACKOFF )); then
          sleep_seconds=${MAX_BACKOFF}
          break
        fi
      done
      sleep "${sleep_seconds}"
    fi
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
