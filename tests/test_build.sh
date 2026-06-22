#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="${ROOT_DIR}/scripts/build.sh"
OUTPUT_FILE="${ROOT_DIR}/.build/output/build-status.json"

assert_file_equals() {
  local actual="$1"
  local expected="$2"

  if ! cmp -s "${actual}" "${expected}"; then
    echo "Expected ${actual} to match ${expected}" >&2
    exit 1
  fi
}

assert_json_status() {
  local file="$1"
  local expected_status="$2"

  python3 - "$file" "$expected_status" <<'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    status = json.load(f).get("status")
if status != sys.argv[2]:
    print(f"Expected status={sys.argv[2]!r}, got {status!r}", file=sys.stderr)
    raise SystemExit(1)
PY
}

rm -rf "${ROOT_DIR}/.build/output" "${ROOT_DIR}/.build/cache"

BUILD_STATUS_URL="https://127.0.0.1:9/unreachable" bash "${BUILD_SCRIPT}" >/dev/null
assert_file_equals "${OUTPUT_FILE}" "${ROOT_DIR}/build-status.json"

cat > "${ROOT_DIR}/.build/cache/build-status.json" <<'JSON'
{
  "status": "cached"
}
JSON

BUILD_STATUS_URL="https://127.0.0.1:9/unreachable" bash "${BUILD_SCRIPT}" >/dev/null
assert_json_status "${OUTPUT_FILE}" "cached"

mv "${ROOT_DIR}/build-status.json" "${ROOT_DIR}/build-status.json.bak"
trap 'mv "${ROOT_DIR}/build-status.json.bak" "${ROOT_DIR}/build-status.json"' EXIT
rm -rf "${ROOT_DIR}/.build/output" "${ROOT_DIR}/.build/cache"

BUILD_STATUS_URL="https://127.0.0.1:9/unreachable" bash "${BUILD_SCRIPT}" >/dev/null
assert_json_status "${OUTPUT_FILE}" "unknown"

mv "${ROOT_DIR}/build-status.json.bak" "${ROOT_DIR}/build-status.json"
trap - EXIT

echo "test_build.sh: ok"
