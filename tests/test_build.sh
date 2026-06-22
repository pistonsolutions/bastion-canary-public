#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

cd "${REPO_ROOT}"

rm -rf .build/output
BUILD_STATUS_URL="http://127.0.0.1:9/unreachable" ./scripts/build.sh >/tmp/test_build_fallback.log 2>&1
cmp -s build-status.json .build/output/build-status.json

tmp_json=$(mktemp)
printf '{"status":"remote-ok"}\n' > "${tmp_json}"
rm -rf .build/output
BUILD_STATUS_URL="file://${tmp_json}" BUILD_FETCH_RETRIES=1 ./scripts/build.sh >/tmp/test_build_remote.log 2>&1
grep -q '"status":"remote-ok"' .build/output/build-status.json

rm -f "${tmp_json}"
echo "build.sh tests passed"
