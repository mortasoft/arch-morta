#!/bin/bash

HOST=arch-linux
USERNAME=mortasoft
HOME_DIR="/home/${USERNAME}"
SWAP_SIZE=4G

echo DISK="sda", HOST="$HOST", USERNAME="$USERNAME", HOME_DIR="$HOME_DIR"
echo "-- Configuring the system --"
read stop

# Grub as a bootloader
grub-install --target=i386-pc --recheck "$1"
echo "-- Grub has been installed --"
read stop

# This makes the grub timeout 0, it's faster than 5 :)
sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
echo "-- Grub timeout configured --"
read stop

# Run these following essential service by default
systemctl enable sshd.service
systemctl enable dhcpcd.service
systemctl enable ntpd.service
echo "-- Services enabled --"
read stop

echo "$HOST" > /etc/hostname
echo "$HOST"
echo "-- Hostname configured --"
read stop

# adding your normal user with additional wheel group so can sudo
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "-- Sudo permissions to user $USERNAME -- " 
read stop

# Adjust your timezone here
ln -f -s /usr/share/zoneinfo/America/Costa_Rica /etc/localtime
hwclock --systohc
echo "-- Timezone and date configured -- " 
read stop

# adjust your name servers here if you don't want to use google
echo 'name_servers="8.8.8.8 8.8.4.4"' >> /etc/resolvconf.conf
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
locale-gen
echo "-- Name servers and language configured -- " 
read stop

# creating the swap file, if you have enough RAM, you can skip this step
fallocate -l "$SWAP_SIZE" /swapfile
chmod 600 /swapfile
mkswap /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab
echo "-- Swapfile created -- " 
read stop

# auto-complete these essential commands
echo complete -cf sudo >> /etc/bash.bashrc
echo complete -cf man >> /etc/bash.bashrc
echo "-- Autocomplete -- " 
read stop