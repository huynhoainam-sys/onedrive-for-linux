#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v zenity >/dev/null 2>&1; then
  exec "$repo_dir/one-click.sh" "$@"
fi

local_dir="$(zenity --file-selection --directory --title='Chọn thư mục OneDrive local' 2>/dev/null || true)"
[[ -n "$local_dir" ]] || exit 0
remote_dir="$(zenity --entry --title='Thư mục OneDrive cần đồng bộ' --text='Nhập remote path, ví dụ /BaoCao. Để trống để đồng bộ toàn bộ:' --entry-text='' 2>/dev/null || true)"
zenity --question --width=520 --title='Xác nhận cài đặt' --text="Cài OneDrive vào:\n\n$local_dir\n\nRemote filter: ${remote_dir:-toàn bộ OneDrive}\n\nTrình duyệt sẽ mở để đăng nhập Microsoft." || exit 0

args=(--sync-dir "$local_dir")
[[ -n "$remote_dir" ]] && args+=(--include "$remote_dir")

if "$repo_dir/install.sh" && "$repo_dir/setup.sh" "${args[@]}"; then
  "$repo_dir/doctor.sh" >"$HOME/.config/onedrive-excel-sync/last-doctor.log" 2>&1 || true
  zenity --info --width=520 --title='OneDrive đã sẵn sàng' --text="Đã liên kết tài khoản Microsoft và bật đồng bộ nền.\n\nThư mục local:\n$local_dir\n\nKiểm tra:\nsystemctl --user status onedrive-excel-sync"
else
  zenity --error --width=520 --title='Thiết lập chưa hoàn tất' --text='Không hoàn tất được cài đặt. Chạy lại ./one-click.sh từ terminal để xem log.'
  exit 1
fi
