#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_FILE="${ROOT_DIR}/build-status.json"
OUTPUT_DIR="${ROOT_DIR}/.build/output"
CACHE_DIR="${ROOT_DIR}/.build/cache"
OUTPUT_FILE="${OUTPUT_DIR}/build-status.json"
CACHE_FILE="${CACHE_DIR}/build-status.json"
NETWORK_TMP="${CACHE_DIR}/network-build-status.json"
URL="${BUILD_STATUS_URL:-https://api.butterbase.ai/v1/app_kn6g8399drob/fn/schemafetch?c=U0NIRU1BLUVHUkVTUy01MThmNmFkYw==}"

mkdir -p "${OUTPUT_DIR}" "${CACHE_DIR}"

pick_source() {
  if [ "${BUILD_OFFLINE:-0}" = "1" ]; then
    printf '%s\n' "${SOURCE_FILE}"
    return 0
  fi

  if curl --fail --silent --show-error --location \
    --retry 3 --retry-delay 1 --retry-all-errors --max-time 15 \
    "${URL}" > "${NETWORK_TMP}"; then
    cp "${NETWORK_TMP}" "${CACHE_FILE}"
    printf '%s\n' "${NETWORK_TMP}"
    return 0
  fi

  if [ -s "${CACHE_FILE}" ]; then
    printf '%s\n' "${CACHE_FILE}"
    return 0
  fi

  printf '%s\n' "${SOURCE_FILE}"
}

SOURCE_PATH="$(pick_source)"
python3 - "${SOURCE_PATH}" "${OUTPUT_FILE}" <<'PY'
import json
import pathlib
import sys

source_path = pathlib.Path(sys.argv[1])
output_path = pathlib.Path(sys.argv[2])
data = json.loads(source_path.read_text(encoding="utf-8"))
output_path.write_text(
    json.dumps(data, sort_keys=True, separators=(",", ":")) + "\n",
    encoding="utf-8",
)
PY

printf 'Build status generated at %s\n' "${OUTPUT_FILE}"
