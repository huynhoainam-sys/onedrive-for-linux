#!/usr/bin/env bash
set -Eeuo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }
[[ "${EUID}" -ne 0 ]] || die "Chạy bằng user thường, không dùng sudo cho toàn bộ script."
command -v sudo >/dev/null || die "Thiếu sudo."
# shellcheck disable=SC1091
. /etc/os-release
[[ "${ID:-}" == "ubuntu" || "${ID_LIKE:-}" == *ubuntu* ]] || die "Chỉ hỗ trợ Ubuntu và biến thể Ubuntu."

echo "[0/4] Cài công cụ bootstrap..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends ca-certificates curl gnupg zenity

if [[ "${ID:-}" == "linuxmint" ]]; then
  case "${VERSION_ID:-}" in
    21|21.*) obs_release="Ubuntu_22.04" ;;
    22|22.*) obs_release="Ubuntu_24.04" ;;
    *) die "Linux Mint ${VERSION_ID:-unknown} chưa có mapping OBS trong repo này." ;;
  esac
else
  case "${VERSION_ID:-}" in
    22.04) obs_release="Ubuntu_22.04" ;;
    24.04) obs_release="Ubuntu_24.04" ;;
    25.10) obs_release="Ubuntu_25.10" ;;
    26.04) obs_release="Ubuntu_26.04" ;;
    *) die "Ubuntu ${VERSION_ID:-unknown} chưa có mapping OBS trong repo này." ;;
  esac
fi

keyring=/usr/share/keyrings/obs-onedrive.gpg
list_file=/etc/apt/sources.list.d/onedrive.list
base="https://download.opensuse.org/repositories/home:/npreining:/debian-ubuntu-onedrive/${obs_release}"
tmp_key="$(mktemp)"
trap 'rm -f "$tmp_key"' EXIT

echo "[1/4] Thêm repository OneDrive được duy trì..."
curl --fail --location --silent --show-error "${base}/Release.key" | gpg --dearmor > "$tmp_key"
sudo install -o root -g root -m 0644 "$tmp_key" "$keyring"
printf 'deb [arch=%s signed-by=%s] %s/ ./\n' "$(dpkg --print-architecture)" "$keyring" "$base" | sudo tee "$list_file" >/dev/null

echo "[2/4] Cài đặt client..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends --no-install-suggests onedrive

echo "[3/4] Tắt service onedrive mặc định để tránh chạy trùng..."
systemctl --user disable --now onedrive.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/onedrive.service"
systemctl --user daemon-reload 2>/dev/null || true

echo "[4/4] Hoàn tất: $(command -v onedrive)"
onedrive --version
echo "Bước tiếp theo: ./setup.sh"
