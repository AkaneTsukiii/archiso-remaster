#!/bin/bash
set -e

# ==============================
# ARCH LINUX AUTO INSTALL MENU
# ==============================

# Check quyền
if [ "$EUID" -ne 0 ]; then
    echo "[!] Bạn đang chạy bằng user thường, sẽ dùng sudo cho lệnh cần root."
    SUDO="sudo"
else
    echo "[+] Bạn đang chạy bằng root."
    SUDO=""
fi

# ==============================
# 1. Chọn ổ đĩa
# ==============================
echo "===> Danh sách ổ đĩa có sẵn:"
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
echo
read -p "Nhập tên ổ để cài (ví dụ: sda, nvme0n1): " DISKNAME
DISK="/dev/$DISKNAME"

if [ ! -b "$DISK" ]; then
    echo "[!] Ổ đĩa $DISK không tồn tại!"
    exit 1
fi

echo "[!] Toàn bộ dữ liệu trên $DISK sẽ bị xoá. Xác nhận (yes/no): "
read CONFIRM
[ "$CONFIRM" != "yes" ] && exit 1

# ==============================
# 2. Partition
# ==============================
echo "===> Tạo phân vùng EFI + ROOT..."
$SUDO parted -s "$DISK" mklabel gpt
$SUDO parted -s "$DISK" mkpart EFI fat32 1MiB 513MiB
$SUDO parted -s "$DISK" set 1 esp on
$SUDO parted -s "$DISK" mkpart ROOT ext4 513MiB 100%

EFI="${DISK}1"
ROOT="${DISK}2"

# ==============================
# 3. LUKS (tùy chọn)
# ==============================
echo "===> Bạn có muốn mã hóa ROOT bằng LUKS?"
select yn in "Có" "Không"; do
    case $yn in
        Có ) 
            $SUDO cryptsetup luksFormat "$ROOT"
            $SUDO cryptsetup open "$ROOT" cryptroot
            ROOT="/dev/mapper/cryptroot"
            break;;
        Không ) break;;
    esac
done

# Format
$SUDO mkfs.fat -F32 "$EFI"
$SUDO mkfs.ext4 -F "$ROOT"

# Mount
$SUDO mount "$ROOT" /mnt
$SUDO mkdir -p /mnt/boot
$SUDO mount "$EFI" /mnt/boot

# ==============================
# 4. Base install
# ==============================
echo "===> Cài base system + tool..."
$SUDO pacstrap /mnt base linux linux-firmware base-devel \
    vim nano htop git curl wget sudo networkmanager cryptsetup

# ==============================
# 5. Swap (tùy chọn)
# ==============================
echo "===> Bạn có muốn tạo swapfile?"
select yn in "Có" "Không"; do
    case $yn in
        Có ) 
            read -p "Dung lượng swapfile (ví dụ: 2G, 4G): " SWAP_SIZE
            $SUDO dd if=/dev/zero of=/mnt/swapfile bs=1M count=$(( ${SWAP_SIZE%G} * 1024 ))
            $SUDO chmod 600 /mnt/swapfile
            $SUDO mkswap /mnt/swapfile
            $SUDO swapon /mnt/swapfile
            echo "/swapfile none swap sw 0 0" | $SUDO tee -a /mnt/etc/fstab
            break;;
        Không ) break;;
    esac
done

# ==============================
# 6. Generate fstab + chroot
# ==============================
$SUDO genfstab -U /mnt >> /mnt/etc/fstab

# Script sau khi chroot
cat << 'EOF' | $SUDO tee /mnt/root/post_chroot.sh > /dev/null
#!/bin/bash
set -e

ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
hwclock --systohc
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "arch" > /etc/hostname

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Root password
echo "===> Đặt mật khẩu cho root:"
passwd

# User setup
read -p "Nhập tên user muốn tạo: " NEWUSER
useradd -m -G wheel -s /bin/bash "$NEWUSER"
echo "===> Đặt mật khẩu cho user $NEWUSER:"
passwd "$NEWUSER"

# sudo cho nhóm wheel
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# ==============================
# Bootloader chọn lựa
# ==============================
echo "===> Chọn bootloader:"
select BL in "GRUB" "systemd-boot" "rEFInd"; do
    case $BL in
        GRUB ) 
            pacman -S --noconfirm grub efibootmgr
            if [ -b /dev/mapper/cryptroot ]; then
                sed -i 's/^HOOKS=(.*)/HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)/' /etc/mkinitcpio.conf
                mkinitcpio -P
                grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
                ROOT_UUID=$(blkid -s UUID -o value /dev/disk/by-partlabel/ROOT)
                sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$ROOT_UUID:cryptroot root=\/dev\/mapper\/cryptroot\"/" /etc/default/grub
            else
                grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch
            fi
            sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& nomodeset/' /etc/default/grub
            grub-mkconfig -o /boot/grub/grub.cfg
            break;;

        systemd-boot )
            bootctl --path=/boot install
            UUID=$(blkid -s UUID -o value /dev/disk/by-partlabel/ROOT)
            mkdir -p /boot/loader/entries
            cat <<EOL > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$UUID rw nomodeset
EOL
            cat <<EOL > /boot/loader/loader.conf
default arch
timeout 3
editor no
EOL
            break;;

        rEFInd )
            pacman -S --noconfirm refind-efi
            refind-install
            UUID=$(blkid -s UUID -o value /dev/disk/by-partlabel/ROOT)
            cat <<EOL > /boot/refind_linux.conf
"Boot Arch Linux"  "root=UUID=$UUID rw nomodeset"
EOL
            break;;
    esac
done

# Enable services
systemctl enable NetworkManager

echo "[+] Cài đặt hoàn tất! Bạn có thể reboot."
EOF

$SUDO chmod +x /mnt/root/post_chroot.sh
$SUDO arch-chroot /mnt /root/post_chroot.sh

echo "[+] Hoàn tất! Hãy reboot để dùng Arch Linux."
