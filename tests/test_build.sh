#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="${ROOT_DIR}/scripts/build.sh"
OUTPUT_FILE="${ROOT_DIR}/.build/output/build-status.json"
BUILD_KEY_FILE="${ROOT_DIR}/.build/output/build-key.txt"

rm -rf "${ROOT_DIR}/.build/cache" "${ROOT_DIR}/.build/output"

"${BUILD_SCRIPT}" >/dev/null
FIRST_HASH="$(sha256sum "${OUTPUT_FILE}" | awk '{print $1}')"
FIRST_KEY="$(cat "${BUILD_KEY_FILE}")"

"${BUILD_SCRIPT}" >/dev/null
SECOND_HASH="$(sha256sum "${OUTPUT_FILE}" | awk '{print $1}')"
SECOND_KEY="$(cat "${BUILD_KEY_FILE}")"

[[ "${FIRST_HASH}" == "${SECOND_HASH}" ]]
[[ "${FIRST_KEY}" == "${SECOND_KEY}" ]]
[[ -f "${ROOT_DIR}/.build/cache/${FIRST_KEY}/build-status.json" ]]

echo "build reproducibility test passed"
