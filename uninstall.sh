#!/usr/bin/env bash
set -Eeuo pipefail
systemctl --user disable --now onedrive-excel-sync.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/onedrive-excel-sync.service"
systemctl --user daemon-reload 2>/dev/null || true
echo "Đã gỡ service. Không xóa file local, cấu hình, hay dữ liệu trên OneDrive."
