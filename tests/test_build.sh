#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$REPO_ROOT/scripts/build.sh" >/tmp/bastion-build-test.out

test -f "$REPO_ROOT/.build/build-status.normalized.json"
test -f "$REPO_ROOT/.build/build-status.sha256"

EXPECTED_SHA="$(cd "$REPO_ROOT/.build" && sha256sum build-status.normalized.json)"
ACTUAL_SHA="$(cat "$REPO_ROOT/.build/build-status.sha256")"

if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
  echo "sha256 mismatch"
  exit 1
fi
