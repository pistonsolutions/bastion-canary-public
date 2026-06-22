#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

cd "${REPO_ROOT}"

tmp_json=""
server_dir=""
server_pid=""
fallback_log="/tmp/test_build_fallback.log"
remote_log="/tmp/test_build_remote.log"
retry_log="/tmp/test_build_retry.log"

cleanup() {
  rm -f "${tmp_json}" 2>/dev/null || true
  if [[ -n "${server_pid}" ]]; then
    kill "${server_pid}" 2>/dev/null || true
    wait "${server_pid}" 2>/dev/null || true
  fi
  rm -rf "${server_dir}" 2>/dev/null || true
  rm -f "${fallback_log}" "${remote_log}" "${retry_log}" 2>/dev/null || true
}
trap cleanup EXIT

if ! command -v python >/dev/null 2>&1; then
  echo "python is required for build.sh tests"
  exit 1
fi

rm -rf .build/output
BUILD_STATUS_URL="http://127.0.0.1:9/unreachable" ./scripts/build.sh >"${fallback_log}" 2>&1
cmp -s build-status.json .build/output/build-status.json || { echo "Fallback test failed: files differ"; exit 1; }

tmp_json=$(mktemp)
printf '{"status":"remote-ok"}\n' > "${tmp_json}"
rm -rf .build/output
BUILD_STATUS_URL="file://${tmp_json}" BUILD_FETCH_RETRIES=1 ./scripts/build.sh >"${remote_log}" 2>&1
grep -q '"status":"remote-ok"' .build/output/build-status.json || { echo "Remote fetch test failed: expected status not found"; exit 1; }

server_dir=$(mktemp -d /tmp/build-retry-test.XXXXXX)
count_file="${server_dir}/count"
port_file="${server_dir}/port"
cat > "${server_dir}/server.py" <<'PY'
import http.server
import os
import socketserver

count_file = os.environ["COUNT_FILE"]
port_file = os.environ["PORT_FILE"]

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            with open(count_file, "r", encoding="utf-8") as f:
                count = int(f.read().strip())
        except Exception:
            count = 0

        count += 1
        with open(count_file, "w", encoding="utf-8") as f:
            f.write(str(count))

        if count == 1:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b"temporary failure")
            return

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(b'{"status":"retry-ok"}')

    def log_message(self, fmt, *args):
        return

with socketserver.TCPServer(("127.0.0.1", 0), Handler) as httpd:
    with open(port_file, "w", encoding="utf-8") as f:
        f.write(str(httpd.server_address[1]))
    httpd.serve_forever()
PY

COUNT_FILE="${count_file}" PORT_FILE="${port_file}" python "${server_dir}/server.py" &
server_pid=$!

for _ in $(seq 1 50); do
  [[ -s "${port_file}" ]] && break
  sleep 0.1
done

[[ -s "${port_file}" ]] || { echo "Retry test setup failed: no server port"; exit 1; }
port=$(cat "${port_file}")

rm -rf .build/output
BUILD_STATUS_URL="http://127.0.0.1:${port}/status" BUILD_FETCH_RETRIES=2 BUILD_MAX_BACKOFF=1 ./scripts/build.sh >"${retry_log}" 2>&1
grep -q '"status":"retry-ok"' .build/output/build-status.json || { echo "Retry test failed: expected status not found"; exit 1; }

echo "build.sh tests passed"
