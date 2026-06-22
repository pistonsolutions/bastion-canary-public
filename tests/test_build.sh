#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "${ROOT_DIR}"
rm -rf .build/output

BUILD_OFFLINE=1 ./scripts/build.sh >/dev/null
hash_one="$(sha256sum .build/output/build-status.json | awk '{print $1}')"

BUILD_OFFLINE=1 ./scripts/build.sh >/dev/null
hash_two="$(sha256sum .build/output/build-status.json | awk '{print $1}')"

test "${hash_one}" = "${hash_two}"
grep -q '"status":"active"' .build/output/build-status.json

echo "build test passed"
