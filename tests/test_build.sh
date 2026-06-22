#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
TMP_DIR="$(mktemp -d /tmp/bastion-build-test.XXXXXX)"
trap 'rm -rf "${TMP_DIR}"' EXIT

assert_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -q --fixed-strings "${expected}" "${file}"; then
    echo "Expected '${expected}' in ${file}" >&2
    exit 1
  fi
}

PORT="$(python - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)"

printf 'dashboard-ok\n' > "${TMP_DIR}/index.html"
python -m http.server "${PORT}" --bind 127.0.0.1 --directory "${TMP_DIR}" > "${TMP_DIR}/server.log" 2>&1 &
SERVER_PID="$!"
trap 'kill "${SERVER_PID}" >/dev/null 2>&1 || true; rm -rf "${TMP_DIR}"' EXIT

cd "${REPO_ROOT}"
rm -f .build/dashcheck.txt .build/output/build-status.json
BUILD_DASHBOARD_URL="http://127.0.0.1:${PORT}/index.html" BUILD_DASHBOARD_MAX_ATTEMPTS=1 BUILD_DASHBOARD_TIMEOUT_SECONDS=2 ./scripts/build.sh

test -f .build/output/build-status.json
assert_contains .build/dashcheck.txt "HTTP 200"
assert_contains .build/dashcheck.txt "dashboard-ok"

if BUILD_DASHBOARD_URL="http://127.0.0.1:9/unreachable" BUILD_DASHBOARD_MAX_ATTEMPTS=1 BUILD_DASHBOARD_TIMEOUT_SECONDS=1 ./scripts/build.sh; then
  echo "Expected build to fail when dashboard is unreachable" >&2
  exit 1
fi

echo "All build script tests passed."
