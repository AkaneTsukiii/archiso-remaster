# Arch Linux ISO Remaster Script

## English

This package provides a script to **remaster the official Arch Linux ISO** with the following customizations:
- Injects your own installer script (`setup.sh`) and manual (`Manual.md`) into `/root/` inside the ISO.
- Enables **`nomodeset`** by default in bootloaders (GRUB, syslinux, and systemd-boot) to prevent black screen issues on some GPUs.
- Outputs a new ISO file named **`arch_custom.iso`**.

### Requirements
- Clean hard drive (dual boot not support)
- `arch.iso` (the official Arch Linux ISO) placed in the same directory as this package.
- Tools: `xorriso`, `squashfs-tools`, `util-linux` (for mounting).
- Root privileges (for mounting ISO and modifying its contents).

### Usage
1. Place the following files in the same folder:
   - `arch.iso` (original Arch ISO - Rename to arch.iso)
   - `remaster-archiso.sh`
   - `setup.sh`

2. Run the script:
   ```bash
   chmod +x remaster-archiso.sh
   ./remaster-archiso.sh

	3.	After completion, you will get a new ISO file:

arch_custom.iso


	4.	Flash the ISO to a USB stick or boot it in a VM.
Inside the live environment, run:

./setup.sh

Tiếng Việt

Gói này cung cấp một script để remaster ISO Arch Linux chính thức với các tùy chỉnh sau:
	-	Chèn script cài đặt (setup.sh) và hướng dẫn (Manual.md) vào /root/ trong ISO.
	-	Bật sẵn nomodeset trong các bootloader (GRUB, syslinux, systemd-boot) để tránh lỗi màn hình đen trên một số GPU.
	-	Xuất ra file ISO mới tên là arch_custom.iso.

Yêu cầu
  - Ổ cứng sạch (không hỗ trợ dual boot)
	-	arch.iso (ISO Arch Linux gốc) đặt cùng thư mục với gói này.
	-	Công cụ: xorriso, squashfs-tools, util-linux (để mount ISO).
	-	Quyền root (để mount và chỉnh sửa ISO).

Cách sử dụng
	1.	Đặt các file sau cùng một thư mục:
	-	arch.iso (ISO gốc của Arch - Đổi tên thành arch.iso)
	-	remaster-archiso.sh
	-	setup.sh
	2.	Chạy script:

chmod +x remaster-archiso.sh
./remaster-archiso.sh


	3.	Sau khi hoàn tất, sẽ có file ISO mới:

arch_custom.iso


	4.	Ghi ISO ra USB hoặc boot trên VM.
Trong môi trường live, chạy:

./setup.sh

### If you want dual boot, please read [The Manual]
