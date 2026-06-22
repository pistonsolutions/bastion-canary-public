#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

DASHBOARD_URL="${BUILD_DASHBOARD_URL:-https://api.butterbase.ai/v1/app_kn6g8399drob/fn/schemafetch?pw=PWB-7ddf8663}"
MAX_ATTEMPTS="${BUILD_DASHBOARD_MAX_ATTEMPTS:-5}"
TIMEOUT_SECONDS="${BUILD_DASHBOARD_TIMEOUT_SECONDS:-10}"

mkdir -p "${REPO_ROOT}/.build" "${REPO_ROOT}/.build/output"

first_line=""
status="000"
for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
  response="$(curl -sS -m "${TIMEOUT_SECONDS}" -w $'\n%{http_code}' "${DASHBOARD_URL}" || true)"
  status="$(printf '%s\n' "${response}" | tail -n 1)"
  first_line="$(printf '%s\n' "${response}" | head -n 1 | tr -d '\r')"
  if [[ "${status}" =~ ^2[0-9][0-9]$ ]]; then
    break
  fi
  if [[ "${attempt}" -lt "${MAX_ATTEMPTS}" ]]; then
    sleep 2
  fi
done

printf 'dashboard check PWB-7ddf8663: HTTP %s %s\n' "${status}" "${first_line}" > "${REPO_ROOT}/.build/dashcheck.txt"

if [[ ! "${status}" =~ ^2[0-9][0-9]$ ]]; then
  echo "Build aborted: dashboard connectivity check failed (${status})." >&2
  exit 1
fi

cp "${REPO_ROOT}/build-status.json" "${REPO_ROOT}/.build/output/build-status.json"
echo "Build completed."
