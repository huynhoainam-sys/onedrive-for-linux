#!/usr/bin/env bash
set -Eeuo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
command -v onedrive >/dev/null || die "Chưa cài onedrive. Chạy ./install.sh trước."
command -v systemctl >/dev/null || die "Thiếu systemctl."
systemctl --user show-environment >/dev/null 2>&1 || die "Không kết nối được user systemd. Hãy chạy trong phiên desktop Linux đã đăng nhập, hoặc kiểm tra XDG_RUNTIME_DIR/DBUS_SESSION_BUS_ADDRESS."

sync_dir="$HOME/OneDrive"
include=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --sync-dir) [[ $# -ge 2 ]] || die "Thiếu giá trị cho --sync-dir"; sync_dir="$2"; shift 2 ;;
    --include) [[ $# -ge 2 ]] || die "Thiếu giá trị cho --include"; include="$2"; shift 2 ;;
    -h|--help) echo "Usage: ./setup.sh [--sync-dir PATH] [--include /RemoteFolder]"; exit 0 ;;
    *) die "Tham số không hợp lệ: $1" ;;
  esac
done

confdir="$HOME/.config/onedrive-excel-sync"
service_dir="$HOME/.config/systemd/user"
mkdir -p "$confdir/logs" "$service_dir" "$sync_dir"

if [[ ! -f "$confdir/config" ]]; then
  cat > "$confdir/config" <<EOF
sync_dir = "$sync_dir"
monitor_interval = "300"
monitor_fullscan_frequency = "12"
enable_logging = "true"
log_dir = "$confdir/logs"
display_transfer_metrics = "true"
skip_file = "~\$*|*.tmp|*.part|*.crdownload|*.lock"
check_nomount = "true"
check_nosync = "true"
EOF
else
  sed -i "s|^sync_dir = .*|sync_dir = \"$sync_dir\"|" "$confdir/config"
fi

ensure_config() {
  local key="$1"
  local value="$2"
  if ! grep -Fq "$key = " "$confdir/config"; then
    printf '%s = "%s"\n' "$key" "$value" >> "$confdir/config"
  fi
}

ensure_config monitor_interval 300
ensure_config monitor_fullscan_frequency 12
ensure_config sync_dir "$sync_dir"
ensure_config enable_logging true
ensure_config log_dir "$confdir/logs"
ensure_config display_transfer_metrics true
ensure_config skip_file '~$*|*.tmp|*.part|*.crdownload|*.lock'
ensure_config check_nomount true
ensure_config check_nosync true

if [[ -n "$include" ]]; then
  printf '%s\n' "$include" > "$confdir/sync_list"
else
  rm -f "$confdir/sync_list"
fi

cat > "$service_dir/onedrive-excel-sync.service" <<EOF
[Unit]
Description=OneDrive Excel Sync
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=$(command -v onedrive) --monitor --confdir="$confdir"
Restart=on-failure
RestartSec=15

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload 2>/dev/null || true
systemctl --user stop onedrive-excel-sync.service 2>/dev/null || true
echo "Thư mục local: $sync_dir"
echo "Đang mở bước đăng nhập Microsoft; hãy chọn ĐÚNG tài khoản OneDrive."
onedrive --confdir="$confdir"

echo "Chạy dry-run có resync để kiểm tra tài khoản và danh sách file..."
onedrive --confdir="$confdir" --sync --resync --verbose --dry-run
read -r -p "Dry-run đúng tài khoản và đúng thư mục? Gõ YES để đồng bộ thật: " answer
[[ "$answer" == "YES" ]] || die "Đã dừng trước khi đồng bộ thật."

onedrive --confdir="$confdir" --sync --resync
systemctl --user enable --now onedrive-excel-sync.service
loginctl enable-linger "$USER" >/dev/null 2>&1 || true
echo "Hoàn tất. Kiểm tra: systemctl --user status onedrive-excel-sync"
