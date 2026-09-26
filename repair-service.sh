#!/usr/bin/env bash
set -Eeuo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }

command -v onedrive >/dev/null || die "Chưa cài onedrive. Chạy ./install.sh trước."
command -v systemctl >/dev/null || die "Thiếu systemctl."
systemctl --user show-environment >/dev/null 2>&1 || die "Không kết nối được user systemd. Hãy chạy lệnh trong phiên desktop Linux đã đăng nhập."

confdir="$HOME/.config/onedrive-excel-sync"
unit="$HOME/.config/systemd/user/onedrive-excel-sync.service"
[[ -f "$confdir/config" ]] || die "Thiếu cấu hình $confdir/config. Chạy ./setup.sh trước."
[[ -f "$unit" ]] || die "Thiếu unit $unit. Chạy ./setup.sh trước."

systemctl --user daemon-reload
systemctl --user enable --now onedrive-excel-sync.service
systemctl --user is-active --quiet onedrive-excel-sync.service || die "Dịch vụ chưa chạy. Xem lỗi bằng: journalctl --user -u onedrive-excel-sync.service -n 50 --no-pager"

echo "Dịch vụ đồng bộ nền đang chạy và tự khởi động khi đăng nhập."
systemctl --user --no-pager --full status onedrive-excel-sync.service
