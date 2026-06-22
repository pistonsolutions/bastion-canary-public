#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="$REPO_ROOT/scripts/build.sh"
OUTPUT_FILE="$REPO_ROOT/.build/output/build-status.json"
SOURCE_FILE="$REPO_ROOT/build-status.json"

rm -rf "$REPO_ROOT/.build/cache" "$REPO_ROOT/.build/output"

first_run="$("$BUILD_SCRIPT")"
[[ "$first_run" == *"build cache: miss"* ]]

second_run="$("$BUILD_SCRIPT")"
[[ "$second_run" == *"build cache: hit"* ]]

cmp -s "$SOURCE_FILE" "$OUTPUT_FILE"

echo "test_build.sh: PASS"
