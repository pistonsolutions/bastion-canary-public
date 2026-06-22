#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_ROOT="$REPO_ROOT/.build/cache"
OUTPUT_ROOT="$REPO_ROOT/.build/output"
ARTIFACT_NAME="build-status.json"
INPUT_FILES=(
  "$REPO_ROOT/build-status.json"
  "$REPO_ROOT/README.md"
)
SOURCE_ARTIFACT="${INPUT_FILES[0]}"

for file in "${INPUT_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "missing required input: $file" >&2
    exit 1
  fi
done

cache_key="$(
  for file in "${INPUT_FILES[@]}"; do
    sha256sum "$file"
  done | sha256sum | awk '{print $1}'
)"
cache_dir="$CACHE_ROOT/$cache_key"
cache_artifact="$cache_dir/$ARTIFACT_NAME"
output_artifact="$OUTPUT_ROOT/$ARTIFACT_NAME"

mkdir -p "$cache_dir" "$OUTPUT_ROOT"

if [[ -f "$cache_artifact" ]]; then
  echo "build cache: hit ($cache_key)"
else
  echo "build cache: miss ($cache_key)"
  cp "$SOURCE_ARTIFACT" "$cache_artifact"
fi

cp "$cache_artifact" "$output_artifact"
echo "build artifact: $output_artifact"
