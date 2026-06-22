#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCKFILE="$SCRIPT_DIR/build.lock"

if [[ ! -f "$LOCKFILE" ]]; then
  echo "Missing lockfile: $LOCKFILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$LOCKFILE"

CURRENT_NODE_VERSION="$(node --version)"
CURRENT_NPM_VERSION="$(npm --version)"
CURRENT_PYTHON_VERSION="$(python3 --version | awk '{print $2}')"
CURRENT_GO_VERSION="$(go version | awk '{print $3}')"

if [[ "$CURRENT_NODE_VERSION" != "$NODE_VERSION" ]]; then
  echo "Pinned NODE_VERSION mismatch: expected $NODE_VERSION, got $CURRENT_NODE_VERSION" >&2
  exit 1
fi
if [[ "$CURRENT_NPM_VERSION" != "$NPM_VERSION" ]]; then
  echo "Pinned NPM_VERSION mismatch: expected $NPM_VERSION, got $CURRENT_NPM_VERSION" >&2
  exit 1
fi
if [[ "$CURRENT_PYTHON_VERSION" != "$PYTHON_VERSION" ]]; then
  echo "Pinned PYTHON_VERSION mismatch: expected $PYTHON_VERSION, got $CURRENT_PYTHON_VERSION" >&2
  exit 1
fi
if [[ "$CURRENT_GO_VERSION" != "$GO_VERSION" ]]; then
  echo "Pinned GO_VERSION mismatch: expected $GO_VERSION, got $CURRENT_GO_VERSION" >&2
  exit 1
fi

mkdir -p "$REPO_ROOT/.build/output"
cp "$REPO_ROOT/build-status.json" "$REPO_ROOT/.build/output/build-status.json"
echo "Build completed with pinned toolchain from $LOCKFILE"
