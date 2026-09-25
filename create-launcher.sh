#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
launcher_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
launcher="${launcher_dir}/onedrive-excel-sync.desktop"
mkdir -p "$launcher_dir"

cat > "$launcher" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=OneDrive Excel Sync - Install
Comment=Install and configure OneDrive Excel synchronization
Exec=x-terminal-emulator -e bash "$repo_dir/one-click.sh"
Icon=folder-cloud
Terminal=false
Categories=Office;Network;
StartupNotify=true
EOF

chmod 0644 "$launcher"
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$launcher_dir" >/dev/null 2>&1 || true
fi

echo "Đã tạo launcher: $launcher"
echo "Mở Applications và chọn: OneDrive Excel Sync - Install"
