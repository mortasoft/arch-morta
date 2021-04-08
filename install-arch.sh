#!/bin/bash
# Based on https://shirotech.com/linux/how-to-automate-arch-linux-installation/
DISK="/dev/sda"
PARTITION="${DISK}1"

echo "-- Disk configuration --"
echo DISK="$DISK", PARTITION="$PARTITION"
read stop
parted -s "$DISK" mklabel msdos
parted -s -a optimal "$DISK" mkpart primary ext4 0% 100%
parted -s "$DISK" set 1 boot on
mkfs.ext4 -F "$PARTITION"
echo "-- The disk has been formatted --"
read stop
fdisk -l

# You can find your closest server from: https://www.archlinux.org/mirrorlist/all/
echo 'Server = http://mirrors.evowise.com/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
mount "$PARTITION" /mnt
echo "-- Updating packages --"
read stop
pacman -Syy

echo "-- Installing Arch Linux into /mnt --"
read stop
# Would recommend to use linux-lts kernel if you are running a server environment, otherwise just use "linux"
pacstrap /mnt $(pacman -Sqg base | sed 's/^linux$/&-lts/') base-devel grub openssh sudo ntp wget vim
genfstab -p /mnt >> /mnt/etc/fstab
echo "-- Installation of packages and fstab has finnished --"
read stop

cp ./chroot.sh /mnt
arch-chroot /mnt ./chroot.sh
rm /mnt/chroot.sh

echo "-- Installation has finished. Ready to umount and reboot --"
read stop
umount -R /mnt
systemctl reboot