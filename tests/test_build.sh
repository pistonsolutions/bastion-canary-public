#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="${ROOT_DIR}/scripts/build.sh"
OUTPUT_FILE="${ROOT_DIR}/.build/output/build-status.json"

rm -rf "${ROOT_DIR}/.build/output" "${ROOT_DIR}/.build/cache"

BUILD_STATUS_URL="https://127.0.0.1:9/unreachable" bash "${BUILD_SCRIPT}" >/dev/null
cmp -s "${OUTPUT_FILE}" "${ROOT_DIR}/build-status.json"

cat > "${ROOT_DIR}/.build/cache/build-status.json" <<'JSON'
{
  "status": "cached"
}
JSON

BUILD_STATUS_URL="https://127.0.0.1:9/unreachable" bash "${BUILD_SCRIPT}" >/dev/null
grep -q '"status": "cached"' "${OUTPUT_FILE}"

mv "${ROOT_DIR}/build-status.json" "${ROOT_DIR}/build-status.json.bak"
trap 'mv "${ROOT_DIR}/build-status.json.bak" "${ROOT_DIR}/build-status.json"' EXIT
rm -rf "${ROOT_DIR}/.build/output" "${ROOT_DIR}/.build/cache"

BUILD_STATUS_URL="https://127.0.0.1:9/unreachable" bash "${BUILD_SCRIPT}" >/dev/null
grep -q '"status": "unknown"' "${OUTPUT_FILE}"

mv "${ROOT_DIR}/build-status.json.bak" "${ROOT_DIR}/build-status.json"
trap - EXIT

echo "test_build.sh: ok"
