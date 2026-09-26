#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$repo_dir"

pause_at_end() {
  local code=$?
  echo
  if [[ "$code" -eq 0 ]]; then
    echo "Hoàn tất. Bạn có thể đóng cửa sổ này."
  else
    echo "Có lỗi (mã $code). Hãy giữ cửa sổ này để xem log."
  fi
  read -r -p "Nhấn Enter để đóng..." _ || true
  exit "$code"
}
trap pause_at_end EXIT

chmod +x install.sh setup.sh gui.sh doctor.sh uninstall.sh

if ! command -v zenity >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] && [[ "${ONEDRIVE_SYNC_BOOTSTRAP:-0}" != "1" ]]; then
  ONEDRIVE_SYNC_BOOTSTRAP=1 ./install.sh
fi

if command -v zenity >/dev/null 2>&1 && [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] && [[ "${ONEDRIVE_SYNC_TERMINAL:-0}" != "1" ]]; then
  "$repo_dir/gui.sh" "$@"
  exit 0
fi

read -r -p "Thư mục local [${HOME}/OneDrive]: " local_dir
local_dir="${local_dir:-$HOME/OneDrive}"
read -r -p "Chỉ đồng bộ thư mục OneDrive nào? Ví dụ /BaoCao (để trống = toàn bộ): " remote_dir

./install.sh

setup_args=(--sync-dir "$local_dir")
if [[ -n "$remote_dir" ]]; then
  setup_args+=(--include "$remote_dir")
fi

./setup.sh "${setup_args[@]}"
./doctor.sh
