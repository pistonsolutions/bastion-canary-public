#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="$REPO_ROOT/scripts/build.sh"
OUTPUT_FILE="$REPO_ROOT/.build/output/build-status.json"
SOURCE_FILE="$REPO_ROOT/build-status.json"

rm -rf "$REPO_ROOT/.build/cache" "$REPO_ROOT/.build/output"

first_run="$("$BUILD_SCRIPT")"
[[ "$first_run" == *"build cache: miss"* ]] || {
  echo "Expected first build to be a cache miss, got: $first_run" >&2
  exit 1
}

second_run="$("$BUILD_SCRIPT")"
[[ "$second_run" == *"build cache: hit"* ]] || {
  echo "Expected second build to be a cache hit, got: $second_run" >&2
  exit 1
}

cmp -s "$SOURCE_FILE" "$OUTPUT_FILE" || {
  echo "Artifact mismatch between $SOURCE_FILE and $OUTPUT_FILE" >&2
  exit 1
}

echo "test_build.sh: PASS"
