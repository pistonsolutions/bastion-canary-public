#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_OUT="$(mktemp)"
TMP_REPO="$(mktemp -d)"
trap 'rm -f "$TMP_OUT"; rm -rf "$TMP_REPO"' EXIT

"$REPO_ROOT/scripts/build.sh" >"$TMP_OUT"

test -f "$REPO_ROOT/.build/build-status.normalized.json"
test -f "$REPO_ROOT/.build/build-status.sha256"

EXPECTED_SHA="$(cd "$REPO_ROOT/.build" && sha256sum build-status.normalized.json | awk '{print $1}')"
ACTUAL_SHA="$(cat "$REPO_ROOT/.build/build-status.sha256")"

if [[ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]]; then
  echo "SHA256 mismatch: expected '$EXPECTED_SHA' but got '$ACTUAL_SHA'"
  exit 1
fi

mkdir -p "$TMP_REPO/scripts"
cp "$REPO_ROOT/scripts/build.sh" "$TMP_REPO/scripts/build.sh"
cp "$REPO_ROOT/build-status.json" "$TMP_REPO/build-status.json"
chmod +x "$TMP_REPO/scripts/build.sh"

if "$TMP_REPO/scripts/build.sh" >/dev/null 2>&1; then
  echo "Expected build to fail when preflight manifest is missing"
  exit 1
fi

mkdir -p "$TMP_REPO/.build"
echo "invalid-manifest" > "$TMP_REPO/.build/env-manifest.b64"
if "$TMP_REPO/scripts/build.sh" >/dev/null 2>&1; then
  echo "Expected build to fail when preflight manifest is invalid"
  exit 1
fi
