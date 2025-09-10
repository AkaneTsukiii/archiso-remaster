# Make Your Own Arch Linux Remaster (Manual Guide)

This document explains how to **remaster the official Arch Linux ISO manually**, so you can add your own installer script and enable `nomodeset` by default.

---

## 1. Requirements
- A Linux system (Arch, Debian, Ubuntu, etc.)
- Install tools:
  ```bash
  sudo pacman -S xorriso squashfs-tools util-linux   # Arch
  # or
  sudo apt install xorriso squashfs-tools mount      # Debian/Ubuntu
  ```
- Files needed:
  - `arch.iso` (official Arch Linux ISO)
  - `setup.sh` (your custom installer)
  - `Manual.md` (installation guide)

---

## 2. Extract ISO
```bash
mkdir mnt iso
sudo mount -o loop arch.iso mnt
cp -rT mnt iso
sudo umount mnt
```

Now the `iso/` folder contains all ISO content.

---

## 3. Add your files
```bash
cp setup.sh iso/root/
cp Manual.md iso/root/
chmod +x iso/root/setup.sh
```

---

## 4. Enable nomodeset

You must edit boot configs in **three places**:

### (a) Syslinux (BIOS boot)
Files: `iso/boot/syslinux/archiso_sys-linux.cfg`, `archiso_pxe-linux.cfg`, `archiso_head.cfg`.

Look for:
```
APPEND initrd=/arch/boot/x86_64/initramfs-linux.img archisobasedir=arch ...
```
Change to:
```
APPEND initrd=/arch/boot/x86_64/initramfs-linux.img archisobasedir=arch ... nomodeset
```

### (b) GRUB (UEFI boot)
File: `iso/boot/grub/loopback.cfg`
```
linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch ...
```
Change to:
```
linux /arch/boot/x86_64/vmlinuz-linux archisobasedir=arch ... nomodeset
```

### (c) systemd-boot (UEFI boot)
File: `iso/loader/entries/archiso-x86_64.conf`
```
options archisobasedir=arch archisolabel=ARCH_YYYYMM ...
```
Change to:
```
options archisobasedir=arch archisolabel=ARCH_YYYYMM ... nomodeset
```

---

## 5. Repack ISO
```bash
xorriso -as mkisofs   -iso-level 3   -full-iso9660-filenames   -volid "ARCH_CUSTOM"   -eltorito-boot isolinux/isolinux.bin     -eltorito-catalog isolinux/boot.cat     -no-emul-boot -boot-load-size 4 -boot-info-table   -eltorito-alt-boot     -e EFI/efiboot.img     -no-emul-boot   -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin   -output arch_custom.iso iso
```

---

## 6. Result
- Output file: `arch_custom.iso`
- Supports **BIOS (Syslinux)** + **UEFI (GRUB + systemd-boot)**
- `nomodeset` is always enabled
- Installer script is included:
  ```bash
  ./setup.sh
  ```

---

## 7. Flash to USB
```bash
sudo dd if=arch_custom.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

Boot from USB and run your installer.

---

✅ Done! You have built your own remastered Arch ISO.
