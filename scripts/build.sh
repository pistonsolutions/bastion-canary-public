#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"${ROOT_DIR}/scripts/preflight-diagnostics.sh"

INPUT_FILE="${ROOT_DIR}/build-status.json"
BUILD_DIR="${ROOT_DIR}/.build"
CACHE_DIR="${BUILD_DIR}/cache"
OUTPUT_DIR="${BUILD_DIR}/output"

if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "Missing input: ${INPUT_FILE}" >&2
  exit 1
fi

mkdir -p "${CACHE_DIR}" "${OUTPUT_DIR}"

BUILD_KEY="$(sha256sum "${INPUT_FILE}" | awk '{print $1}')"
CACHE_KEY_DIR="${CACHE_DIR}/${BUILD_KEY}"
CACHE_OUTPUT="${CACHE_KEY_DIR}/build-status.json"
OUTPUT_FILE="${OUTPUT_DIR}/build-status.json"

if [[ ! -f "${CACHE_OUTPUT}" ]]; then
  mkdir -p "${CACHE_KEY_DIR}"
  LC_ALL=C TZ=UTC SOURCE_DATE_EPOCH=0 \
  python3 - "${INPUT_FILE}" "${CACHE_OUTPUT}" <<'PY'
import json
import sys

source_path, output_path = sys.argv[1], sys.argv[2]
with open(source_path, encoding="utf-8") as source_file:
    data = json.load(source_file)

with open(output_path, "w", encoding="utf-8", newline="\n") as output_file:
    json.dump(data, output_file, sort_keys=True, separators=(",", ":"))
    output_file.write("\n")
PY

  cat > "${CACHE_KEY_DIR}/build-status.json.meta" <<META
{"build_key":"${BUILD_KEY}","source":"build-status.json"}
META
fi

cp "${CACHE_OUTPUT}" "${OUTPUT_FILE}"
printf '%s\n' "${BUILD_KEY}" > "${OUTPUT_DIR}/build-key.txt"
printf 'Reproducible build artifact: %s\n' "${OUTPUT_FILE}"
