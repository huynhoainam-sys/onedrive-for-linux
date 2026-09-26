#!/usr/bin/env bash
set -Eeuo pipefail

ok=0
warn=0
fail=0
check() { printf '[OK]   %s\n' "$1"; ok=$((ok + 1)); }
warning() { printf '[WARN] %s\n' "$1"; warn=$((warn + 1)); }
error() { printf '[FAIL] %s\n' "$1"; fail=$((fail + 1)); }

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" == "ubuntu" || "${ID:-}" == "linuxmint" || "${ID_LIKE:-}" == *ubuntu* ]]; then
    check "Ubuntu/Linux Mint detected: ${PRETTY_NAME:-unknown}"
  else
    error "Unsupported OS: ${PRETTY_NAME:-unknown}"
  fi
else
  error "Cannot read /etc/os-release"
fi

if command -v onedrive >/dev/null 2>&1; then
  check "onedrive binary: $(command -v onedrive)"
else
  error "onedrive is not installed"
fi

confdir="$HOME/.config/onedrive-excel-sync"
if [[ -f "$confdir/config" ]]; then
  check "configuration exists: $confdir/config"
else
  error "configuration is missing: $confdir/config"
fi

if [[ -f "$confdir/refresh_token" ]]; then
  check "Microsoft authorization token exists"
else
  warning "No authorization token; run ./setup.sh to link the intended Microsoft account"
fi

if systemctl --user is-enabled --quiet onedrive-excel-sync.service 2>/dev/null; then
  check "systemd service is enabled"
else
  warning "systemd service is not enabled; run ./repair-service.sh from a logged-in desktop session"
fi

if systemctl --user is-active --quiet onedrive-excel-sync.service 2>/dev/null; then
  check "systemd service is active"
else
  warning "systemd service is not active; run ./repair-service.sh from a logged-in desktop session"
fi

if [[ -f "$confdir/config" ]] && grep -q '^sync_dir = ' "$confdir/config"; then
  sync_dir="$(sed -n 's/^sync_dir = "\(.*\)"$/\1/p' "$confdir/config" | head -n 1)"
  if [[ -n "$sync_dir" && -d "$sync_dir" ]]; then
    check "sync directory exists: $sync_dir"
  else
    warning "sync directory is missing or cannot be resolved: $sync_dir"
  fi
fi

printf '\nSummary: %d OK, %d warning, %d failure\n' "$ok" "$warn" "$fail"
[[ "$fail" -eq 0 ]]
