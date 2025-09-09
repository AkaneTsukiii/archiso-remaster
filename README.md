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
   `chmod +x remaster-archiso.sh
   ./remaster-archiso.sh`

	3.	After completion, you will get a new ISO file:

arch_custom.iso


	4.	Flash the ISO to a USB stick or boot it in a VM.
Inside the live environment, run:

./setup.sh

### If you want dual boot, please do not use this script for your archiso
