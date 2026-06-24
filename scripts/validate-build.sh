#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_FILE="${1:-$REPO_ROOT/build-status.json}"

python3 - "$TARGET_FILE" <<'PY'
import json
import sys

path = sys.argv[1]

try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
except FileNotFoundError:
    print(f"error: file not found: {path}", file=sys.stderr)
    raise SystemExit(1)
except json.JSONDecodeError as err:
    print(f"error: invalid JSON in {path}: {err}", file=sys.stderr)
    raise SystemExit(1)

if not isinstance(data, dict):
    print(f"error: top-level JSON must be an object in {path}", file=sys.stderr)
    raise SystemExit(1)

if "status" not in data:
    print(f"error: missing required 'status' field in {path}", file=sys.stderr)
    raise SystemExit(1)

print(f"ok: {path} contains valid JSON with a status field")
PY
