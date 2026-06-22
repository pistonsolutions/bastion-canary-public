#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_UNDER_TEST="$REPO_ROOT/scripts/build.sh"

assert_contains() {
  local needle="$1"
  local file="$2"
  if ! grep -q "$needle" "$file"; then
    echo "Expected '$needle' in $file"
    cat "$file"
    exit 1
  fi
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
port="$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)"
(
  cd "$fixture/web"
  python3 -m http.server "$port" --bind 127.0.0.1 >/dev/null 2>&1 &
  echo $! > "$fixture/server.pid"
)
sleep 1
(
  cd "$fixture"
  BUILD_STATUS_URL="http://127.0.0.1:$port/build-status.json" ./scripts/build.sh >/dev/null
)
kill "$(cat "$fixture/server.pid")" >/dev/null 2>&1 || true
assert_contains 'url' "$fixture/.build/output/build-status.json"
assert_contains 'url' "$fixture/.build/cache/build-status.json"

# Falls back to unknown when no source is available.
fixture="$(new_fixture)"
run_build "$fixture"
assert_contains 'unknown' "$fixture/.build/output/build-status.json"

echo "All build script tests passed"
