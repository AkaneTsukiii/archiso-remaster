#!/bin/bash
set -e

# ===============================
# Arch ISO Remaster Script
# ===============================
# Yêu cầu:
#   - File arch.iso (Arch Linux gốc)
#   - File setup.sh (script installer)
#   - File Manual.md (hướng dẫn)
#   - Chạy script này trong thư mục chứa 3 file trên
#
# Kết quả: arch_custom.iso
# ===============================

ISO_IN="arch.iso"
ISO_OUT="arch_custom.iso"
WORKDIR="iso"

# Check file
for f in "$ISO_IN" "setup.sh" "Manual.md"; do
    if [ ! -f "$f" ]; then
        echo "[!] Thiếu file: $f"
        exit 1
    fi
done

# Cleanup
rm -rf mnt "$WORKDIR"
mkdir -p mnt "$WORKDIR"

# Mount ISO gốc
echo "[+] Mount ISO gốc..."
sudo mount -o loop "$ISO_IN" mnt

# Copy nội dung ISO ra thư mục làm việc
echo "[+] Copy dữ liệu ISO..."
cp -rT mnt "$WORKDIR"

# Unmount
sudo umount mnt

# Copy script vào /root trong ISO
echo "[+] Chèn script setup.sh và Manual.md..."
cp setup.sh "$WORKDIR/root/"
cp Manual.md "$WORKDIR/root/"
chmod +x "$WORKDIR/root/setup.sh"

# Thêm nomodeset vào các boot config
echo "[+] Thêm nomodeset vào boot options..."
# GRUB
sed -i 's|\(linux /arch/boot/x86_64/vmlinuz-linux.*\)|\1 nomodeset|' \
    "$WORKDIR/boot/grub/grub.cfg"

# Syslinux
sed -i 's|append initrd=/arch/boot/x86_64/initramfs-linux.img.*|& nomodeset|' \
    "$WORKDIR/isolinux/isolinux.cfg"
sed -i 's|append initrd=/arch/boot/x86_64/initramfs-linux.img.*|& nomodeset|' \
    "$WORKDIR/syslinux/archiso_sys.cfg"
sed -i 's|append initrd=/arch/boot/x86_64/initramfs-linux.img.*|& nomodeset|' \
    "$WORKDIR/syslinux/archiso_pxe.cfg"

# systemd-boot
for entry in "$WORKDIR"/loader/entries/*.conf; do
    sed -i 's|options .*|& nomodeset|' "$entry"
done

# Repack ISO
echo "[+] Tạo ISO mới: $ISO_OUT ..."
xorriso -as mkisofs -iso-level 3 -full-iso9660-filenames \
  -volid "ARCH_CUSTOM" -eltorito-boot isolinux/isolinux.bin \
  -eltorito-catalog isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
  -output "$ISO_OUT" "$WORKDIR"

echo "[✔] Hoàn tất! File ISO mới: $ISO_OUT"
