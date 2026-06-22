#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/build.sh"
MAX_SERVER_STARTUP_ATTEMPTS=5
SERVER_POLL_INTERVAL_SECONDS=0.2

assert_contains() {
  local needle="$1"
  local file="$2"
  if ! grep -q "$needle" "$file"; then
    echo "Expected '$needle' in $file"
    cat "$file"
    exit 1
  fi
}

server_is_ready() {
  local port="$1"
  case "$port" in
    UNSET|'')
      return 1
      ;;
  esac
  curl -fsS --max-time 2 "http://127.0.0.1:$port/build-status.json" >/dev/null 2>&1
}

run_build() {
  local dir="$1"
  (
    cd "$dir"
    ./scripts/build.sh >/dev/null
  )
}

new_fixture() {
  local dir
  dir="$(mktemp -d)"
  mkdir -p "$dir/scripts"
  cp "$SCRIPT_UNDER_TEST" "$dir/scripts/build.sh"
  chmod +x "$dir/scripts/build.sh"
  echo "$dir"
}

# Falls back to repo build-status.json and writes diagnostics output.
fixture="$(new_fixture)"
printf '{"status":"repo"}\n' > "$fixture/build-status.json"
run_build "$fixture"
assert_contains 'repo' "$fixture/.build/output/build-status.json"
assert_contains 'timestamp_utc=' "$fixture/.build/output/runtime-network-diagnostics.txt"

# Uses cache when URL fetch fails.
fixture="$(new_fixture)"
mkdir -p "$fixture/.build/cache"
printf '{"status":"cache"}\n' > "$fixture/.build/cache/build-status.json"
(
  cd "$fixture"
  BUILD_STATUS_URL="http://127.0.0.1:9/unreachable" ./scripts/build.sh >/dev/null
)
assert_contains 'cache' "$fixture/.build/output/build-status.json"

# Uses URL when available and refreshes cache.
fixture="$(new_fixture)"
mkdir -p "$fixture/web"
printf '{"status":"url"}\n' > "$fixture/web/build-status.json"
(
  cd "$fixture/web"
  python3 - "$fixture/server.port" <<'PY' >/dev/null 2>&1 &
import http.server
import socketserver
import sys

port_file = sys.argv[1]

class Handler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, fmt, *args):
        pass

with socketserver.TCPServer(("127.0.0.1", 0), Handler) as server:
    with open(port_file, "w", encoding="utf-8") as f:
        f.write(str(server.server_address[1]))
    server.serve_forever()
PY
  echo "$!" > "$fixture/server.pid"
)
cleanup_server() {
  if [ -f "$fixture/server.pid" ]; then
    kill "$(cat "$fixture/server.pid")" >/dev/null 2>&1 || true
  fi
}
trap cleanup_server EXIT
port="UNSET"
attempt=1
while [ "$attempt" -le "$MAX_SERVER_STARTUP_ATTEMPTS" ]; do
  if [ -s "$fixture/server.port" ]; then
    port="$(cat "$fixture/server.port")"
  fi
  if server_is_ready "$port"; then
    break
  fi
  sleep "$SERVER_POLL_INTERVAL_SECONDS"
  attempt=$((attempt + 1))
done
if ! server_is_ready "$port"; then
  echo "Failed to start local test HTTP server"
  exit 1
fi
(
  cd "$fixture"
  BUILD_STATUS_URL="http://127.0.0.1:$port/build-status.json" ./scripts/build.sh >/dev/null
)
cleanup_server
assert_contains 'url' "$fixture/.build/output/build-status.json"
assert_contains 'url' "$fixture/.build/cache/build-status.json"

# Falls back to unknown when no source is available.
fixture="$(new_fixture)"
run_build "$fixture"
assert_contains 'unknown' "$fixture/.build/output/build-status.json"

echo "All build script tests passed"
