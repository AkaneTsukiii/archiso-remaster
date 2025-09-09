# Arch Linux Auto Installer - Hướng dẫn sử dụng

Script này giúp bạn cài đặt Arch Linux tự động với các tùy chọn:
- Chọn ổ đĩa cài đặt
- Tùy chọn mã hóa LUKS
- Tạo swapfile
- Chọn bootloader (GRUB, systemd-boot, rEFInd)
- Cấu hình root + user + sudo
- Bật sẵn `nomodeset` để tránh lỗi màn hình khi cài

---

## Cách sử dụng

1. Tải file nén và giải nén:
   ```bash
   unzip arch_installer.zip
   cd arch_installer
   ```

2. Chạy script (nếu bạn đã ở môi trường Arch ISO LiveCD):
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

---

## Tùy chọn Bootloader

### 1. GRUB
- Hỗ trợ cả BIOS và UEFI.
- Hỗ trợ LUKS encryption.
- Hỗ trợ multiboot.
- Script sẽ tự động cài `grub` và thêm `nomodeset` vào kernel command line.

### 2. systemd-boot
- Chỉ dùng được với UEFI.
- Cấu hình đơn giản, nhẹ, nhanh.
- Script sẽ tạo `arch.conf` trong `/boot/loader/entries/` với tùy chọn `nomodeset`.

### 3. rEFInd
- Chỉ dùng được với UEFI.
- Giao diện đẹp, dễ sử dụng, tự động nhận kernel.
- Script sẽ cài `refind` và thêm file `/boot/refind_linux.conf` với tùy chọn `nomodeset`.

---

## Lưu ý
- `nomodeset` bật mặc định, bạn có thể tắt sau khi cài driver GPU (NVIDIA/AMD/Intel).
- Nếu cài trên máy BIOS legacy, script sẽ chỉ dùng **GRUB**.
- Nếu bật LUKS, bạn cần nhập mật khẩu khi boot.
