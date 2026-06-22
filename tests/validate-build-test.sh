#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALIDATOR="$REPO_ROOT/scripts/validate-build.sh"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

cat >"$TMP_DIR/valid.json" <<'JSON'
{
  "status": "active"
}
JSON

cat >"$TMP_DIR/missing-status.json" <<'JSON'
{
  "state": "active"
}
JSON

echo '{' >"$TMP_DIR/invalid.json"

"$VALIDATOR" "$TMP_DIR/valid.json" >/dev/null

if "$VALIDATOR" "$TMP_DIR/missing-status.json" >/dev/null 2>&1; then
  echo "expected missing-status.json to fail validation" >&2
  exit 1
fi

if "$VALIDATOR" "$TMP_DIR/invalid.json" >/dev/null 2>&1; then
  echo "expected invalid.json to fail validation" >&2
  exit 1
fi

echo "validate-build-test: PASS"
