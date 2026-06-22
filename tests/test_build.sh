#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="$ROOT_DIR/scripts/build.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

MOCK_CURL="$TMP_DIR/mock-curl.sh"
cat > "$MOCK_CURL" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

OUT_FILE=""
ARGS=("$@")
for ((i=0; i<${#ARGS[@]}; i++)); do
  if [[ "${ARGS[$i]}" == "-o" ]]; then
    OUT_FILE="${ARGS[$((i+1))]}"
    break
  fi
done

if [[ -z "$OUT_FILE" ]]; then
  echo "missing output file" >&2
  exit 2
fi

if [[ " $* " == *" --resolve api.butterbase.ai:443:66.241.125.128 "* ]]; then
  printf '{"status":"ok","transport":"ip-resolve"}\n' > "$OUT_FILE"
  exit 0
fi

exit 7
EOF
chmod +x "$MOCK_CURL"

OUTPUT_FILE="$TMP_DIR/dependency-schema.json"
LOG_FILE="$TMP_DIR/build.log"
if ! BUILD_SCHEMA_URL="https://api.butterbase.ai/v1/app_kn6g8399drob/fn/schemafetch?test=1" \
  BUILD_OUTPUT_FILE="$OUTPUT_FILE" \
  CURL_BIN="$MOCK_CURL" \
  "$BUILD_SCRIPT" >"$LOG_FILE" 2>&1; then
  cat "$LOG_FILE" >&2
  echo "build script failed unexpectedly" >&2
  exit 1
fi

grep -q "Dependency fetch attempt: hostname-https" "$LOG_FILE"
grep -q "Dependency fetch attempt: ip-resolve-https" "$LOG_FILE"
grep -q "Dependency fetch succeeded via ip-resolve-https" "$LOG_FILE"
grep -q '"transport":"ip-resolve"' "$OUTPUT_FILE"

echo "test_build.sh: PASS"
