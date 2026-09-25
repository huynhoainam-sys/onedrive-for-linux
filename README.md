# OneDrive for Linux
Bộ cài nhanh để liên kết một tài khoản Microsoft OneDrive và đồng bộ file Excel trên Ubuntu/Linux Mint. Hỗ trợ Ubuntu 22.04/24.04 và Linux Mint 21.x/22.x.

Engine sử dụng [abraunegg/onedrive](https://github.com/abraunegg/onedrive), hỗ trợ theo dõi thay đổi local bằng `inotify`, cập nhật cloud qua monitor mode và chạy nền bằng `systemd --user`.
## Cài từ GitHub
```bash
git clone https://github.com/huynhoainam-sys/onedrive-for-linux.git
cd onedrive-for-linux
chmod +x create-launcher.sh one-click.sh
./create-launcher.sh
```
Sau đó mở menu Applications và chọn `OneDrive for Linux - Install`. Launcher sẽ hỏi thư mục local và thư mục OneDrive, cài dependency, mở đăng nhập Microsoft, chạy `resync --dry-run`, rồi tạo service đồng bộ nền.

Hoặc chạy trực tiếp giao diện:

```bash
./one-click.sh
```

GUI cho phép chọn thư mục local, chọn thư mục OneDrive cần đồng bộ, cài client, mở đăng nhập Microsoft và bật service nền. Mặc định thư mục là `~/OneDrive-Excel`; có thể chọn `~/OneDrive`.
## Cài trực tiếp bằng terminal
```bash
./install.sh
./setup.sh
```
Khi đăng nhập Microsoft, hãy chọn đúng tài khoản OneDrive. Mặc định thư mục local là `~/OneDrive-Excel`. Chỉ đồng bộ một thư mục:
```bash
./setup.sh --sync-dir "$HOME/OneDrive-Excel" --include /BaoCao
```
## Kiểm tra

```bash
./doctor.sh
systemctl --user status onedrive-excel-sync
journalctl --user-unit=onedrive-excel-sync -f
```

## Tự động lưu Excel

Client đồng bộ sau khi ứng dụng ghi file xuống đĩa. Với LibreOffice, bật AutoSave trong Options và lưu workbook bên trong thư mục OneDrive. Microsoft Excel desktop không có bản native chính thức cho Linux; Excel Online hoặc Excel chạy trong VM/Wine cần lưu vào đúng thư mục local này.

Không nên cùng lúc sửa cùng một workbook trên nhiều máy. Client có cơ chế bảo toàn dữ liệu khi phát hiện xung đột, nhưng không thể gộp an toàn mọi thay đổi trong file `.xlsx`.

## Kiểm thử

```bash
bash tests/smoke.sh
shellcheck *.sh tests/smoke.sh
```

GitHub Actions tự kiểm tra script trên Ubuntu 22.04 và 24.04.
## LibreOffice Calc
Vào `Tools → Options → Load/Save → General`, bật `Save AutoRecovery information every` (5 phút), `Automatically save the document too` và `Always create a backup copy`. Mở file `.xlsx` từ thư mục local để thay đổi được OneDrive client đồng bộ lên cloud.
## Lưu ý
- Không mở cùng một file trên Windows và Linux cùng lúc.
- Không đặt thư mục đồng bộ trên NFS/SMB nếu cần phát hiện thay đổi gần thời gian thực.
- `uninstall.sh` không xóa file local hoặc file trên OneDrive.
