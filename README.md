# OneDrive Excel Sync for Ubuntu
Bộ cài nhanh để liên kết một tài khoản Microsoft OneDrive và đồng bộ file Excel trên Ubuntu/Linux Mint. Hỗ trợ Ubuntu 22.04/24.04 và Linux Mint 21.x/22.x.
## Cài từ GitHub
```bash
git clone https://github.com/huynhoainam-sys/onedrive-excel-sync.git
cd onedrive-excel-sync
chmod +x create-launcher.sh one-click.sh
./create-launcher.sh
```
Sau đó mở menu Applications và chọn `OneDrive Excel Sync - Install`. Launcher sẽ hỏi thư mục local và thư mục OneDrive, cài dependency, mở đăng nhập Microsoft, chạy `resync --dry-run`, rồi tạo service đồng bộ nền.
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
onedrive --confdir="$HOME/.config/onedrive-excel-sync" --display-sync-status
journalctl --user -u onedrive-excel-sync -f
```
## LibreOffice Calc
Vào `Tools → Options → Load/Save → General`, bật `Save AutoRecovery information every` (5 phút), `Automatically save the document too` và `Always create a backup copy`. Mở file `.xlsx` từ thư mục local để thay đổi được OneDrive client đồng bộ lên cloud.
## Lưu ý
- Không mở cùng một file trên Windows và Linux cùng lúc.
- Không đặt thư mục đồng bộ trên NFS/SMB nếu cần phát hiện thay đổi gần thời gian thực.
- `uninstall.sh` không xóa file local hoặc file trên OneDrive.
