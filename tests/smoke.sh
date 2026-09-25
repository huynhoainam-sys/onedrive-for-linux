#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
scripts=(install.sh setup.sh one-click.sh gui.sh create-launcher.sh doctor.sh uninstall.sh)
for script in "${scripts[@]}"; do
  [[ -f "$repo_dir/$script" ]] || { echo "Missing: $script" >&2; exit 1; }
  bash -n "$repo_dir/$script"
done
grep -q -- '--monitor' "$repo_dir/setup.sh"
grep -q 'systemctl --user enable --now' "$repo_dir/setup.sh"
grep -q 'zenity' "$repo_dir/gui.sh"
echo "smoke-test=PASS"
