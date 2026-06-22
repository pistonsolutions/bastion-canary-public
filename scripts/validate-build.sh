#!/usr/bin/env bash
set -euo pipefail

BUILD_STATUS_FILE="${1:-build-status.json}"

python3 - "$BUILD_STATUS_FILE" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
if not path.exists():
    print(f"Validation failed: {path} does not exist.", file=sys.stderr)
    sys.exit(1)

try:
    data = json.loads(path.read_text())
except json.JSONDecodeError as exc:
    print(f"Validation failed: invalid JSON in {path}: {exc}", file=sys.stderr)
    sys.exit(1)

if not isinstance(data, dict) or "status" not in data:
    print(f"Validation failed: {path} must contain a top-level 'status' field.", file=sys.stderr)
    sys.exit(1)

print(f"Validation passed: {path} contains a 'status' field.")
PY
