# OneDrive Excel Sync for Ubuntu

Bộ cài nhanh cho Ubuntu để liên kết một tài khoản Microsoft OneDrive, đồng bộ thư mục cục bộ bằng `onedrive` client của abraunegg, chạy nền bằng systemd và lưu file Excel tự động qua LibreOffice Calc.

Hỗ trợ Ubuntu 22.04/24.04 và Linux Mint 21.x/22.x (Mint được ánh xạ sang nền Ubuntu tương ứng).

## Cài đặt nhanh

```bash
git clone <repo-url> onedrive-excel-sync
cd onedrive-excel-sync
chmod +x install.sh setup.sh doctor.sh uninstall.sh
./install.sh
./setup.sh
```

## Chạy bằng một click trên Linux

Sau khi giải nén, chạy một lần:

```bash
chmod +x create-launcher.sh one-click.sh
./create-launcher.sh
```

Sau đó mở menu Applications và chọn `OneDrive Excel Sync - Install`. Launcher sẽ mở terminal, hỏi thư mục local/thư mục OneDrive cần đồng bộ, cài dependency, xác thực tài khoản Microsoft và tạo service chạy nền.

`setup.sh` sẽ mở trình duyệt để đăng nhập Microsoft. Hãy dùng cửa sổ riêng tư hoặc đăng xuất các tài khoản Microsoft khác để chọn đúng tài khoản.

Lần chạy đầu dùng `--resync --dry-run`, sau đó mới hỏi xác nhận `YES`. Đây là lớp kiểm tra để tránh đẩy nhầm file vào tài khoản hoặc thư mục sai.

Mặc định thư mục local là `~/OneDrive-Excel`.

## Cài từ GitHub trên PC khác

Sau khi repository được đưa lên GitHub:

```bash
git clone https://github.com/OWNER/REPOSITORY.git
cd REPOSITORY
chmod +x create-launcher.sh one-click.sh
./create-launcher.sh
```

Sau đó chạy `OneDrive Excel Sync - Install` từ menu Applications. Không chạy toàn bộ installer bằng `sudo`; script chỉ dùng `sudo` cho các bước apt cần quyền quản trị.

## Chỉ đồng bộ một thư mục

```bash
./setup.sh --sync-dir "$HOME/OneDrive-Excel" --include /BaoCao
```

File sẽ nằm tại `~/OneDrive-Excel/BaoCao/`. Bỏ `--include` nếu muốn đồng bộ toàn bộ OneDrive.

## Kiểm tra

```bash
systemctl --user status onedrive-excel-sync
onedrive --confdir="$HOME/.config/onedrive-excel-sync" --display-sync-status
journalctl --user -u onedrive-excel-sync -f
./doctor.sh
```

## Cấu hình LibreOffice Calc

Trong LibreOffice: `Tools → Options → Load/Save → General`.

Bật `Save AutoRecovery information every` (5 phút), `Automatically save the document too` và `Always create a backup copy`. Mở file Excel từ thư mục local, ví dụ `~/OneDrive-Excel/BaoCao/report.xlsx`. Khi Calc lưu file, service sẽ tải thay đổi lên OneDrive.

## Lưu ý

- Luôn chạy dry-run trong `setup.sh` trước lần đồng bộ đầu tiên.
- Không mở cùng một file trên Windows và Ubuntu cùng lúc.
- Không đặt thư mục đồng bộ trên NFS/SMB nếu cần phát hiện thay đổi gần thời gian thực.
- `uninstall.sh` không xóa file local hoặc file trên OneDrive.
