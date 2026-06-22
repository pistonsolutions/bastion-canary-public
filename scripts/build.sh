#!/usr/bin/env bash
set -euo pipefail

RUNTIME_ROOT="/opt/copilot-runtime/copilot-developer-action-main/dist-cca-v3"
# Recompute these pins from the runtime being validated:
# 1) find "$RUNTIME_ROOT" -name package.json ... | sort -u | sha256sum
# 2) sha256sum "$RUNTIME_ROOT/package.json" "$RUNTIME_ROOT/package-lock.json"
PINNED_INVENTORY_SHA256="ba11b14a65ec4b4f40325c80618779cf2eed32da29042f53bd8a084fac5997c2"
PINNED_PACKAGE_JSON_SHA256="ab4db788739db08cb18f165bb514ad5465b73d875f7ccaece02714cb41bcdd42"
PINNED_PACKAGE_LOCK_SHA256="9e82cf27d98acc86a760a9b4507340d127754db0e366f0cfe9cc3ce48f35185a"

if [[ ! -d "$RUNTIME_ROOT" ]]; then
  echo "Missing runtime directory: $RUNTIME_ROOT" >&2
  exit 1
fi

inventory="$(
  find "$RUNTIME_ROOT" -name package.json 2>/dev/null | while read -r f; do
    node -e "try{let d=require('$f');if(d.name)console.log(d.name+'@'+d.version)}catch(e){}" 2>/dev/null
  done | sort -u
)"

actual_inventory_sha="$(printf '%s\n' "$inventory" | sha256sum | awk '{print $1}')"
actual_package_json_sha="$(sha256sum "$RUNTIME_ROOT/package.json" | awk '{print $1}')"
actual_package_lock_sha="$(sha256sum "$RUNTIME_ROOT/package-lock.json" | awk '{print $1}')"

if [[ "$actual_inventory_sha" != "$PINNED_INVENTORY_SHA256" ]]; then
  echo "Runtime dependency inventory hash mismatch." >&2
  echo "Expected: $PINNED_INVENTORY_SHA256" >&2
  echo "Actual:   $actual_inventory_sha" >&2
  exit 1
fi

if [[ "$actual_package_json_sha" != "$PINNED_PACKAGE_JSON_SHA256" ]]; then
  echo "Runtime package.json hash mismatch." >&2
  echo "Expected: $PINNED_PACKAGE_JSON_SHA256" >&2
  echo "Actual:   $actual_package_json_sha" >&2
  exit 1
fi

if [[ "$actual_package_lock_sha" != "$PINNED_PACKAGE_LOCK_SHA256" ]]; then
  echo "Runtime package-lock.json hash mismatch." >&2
  echo "Expected: $PINNED_PACKAGE_LOCK_SHA256" >&2
  echo "Actual:   $actual_package_lock_sha" >&2
  exit 1
fi

echo "copilot-runtime dependency pin verification passed."
