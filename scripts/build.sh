#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_STATUS_FILE="$REPO_ROOT/build-status.json"
BUILD_DIR="$REPO_ROOT/.build"
ENV_MANIFEST_FILE="$BUILD_DIR/env-manifest.b64"
NORMALIZED_STATUS_FILE="$BUILD_DIR/build-status.normalized.json"
STATUS_SHA_FILE="$BUILD_DIR/build-status.sha256"

if [[ ! -s "$ENV_MANIFEST_FILE" ]]; then
  echo "Missing required preflight manifest: $ENV_MANIFEST_FILE" >&2
  echo "Run: mkdir -p .build && env | sort | base64 | tr -d '\\n' > .build/env-manifest.b64" >&2
  exit 1
fi

python3 - "$BUILD_STATUS_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

if not isinstance(data, dict):
    raise SystemExit("build-status.json must be a JSON object")

status = data.get("status")
if status != "active":
    raise SystemExit("build-status.json must contain status=active")
PY

mkdir -p "$BUILD_DIR"
python3 - "$BUILD_STATUS_FILE" "$NORMALIZED_STATUS_FILE" <<'PY'
import json
import sys

src, dst = sys.argv[1], sys.argv[2]
with open(src, "r", encoding="utf-8") as f:
    data = json.load(f)

with open(dst, "w", encoding="utf-8") as f:
    json.dump(data, f, sort_keys=True, separators=(",", ":"))
PY

(
  cd "$BUILD_DIR"
  sha256sum "$(basename "$NORMALIZED_STATUS_FILE")" > "$(basename "$STATUS_SHA_FILE")"
)

echo "Build complete: $NORMALIZED_STATUS_FILE"
