#!/bin/bash

loadkeys ru
setfont cyr-sun16

echo 'Синхронизация системных часов'
timedatectl set-ntp true
echo 'Проверка режима загрузки'
echo 'Если содержимое отображается без каких-либо ошибок, система загружена в режиме UEFI.'
ls /sys/firmware/efi/efivars
echo 'Проверка сетевого интерфейс'
ip link
ping archlinux.org

echo 'Создание разделов'
(
 echo g;

 echo n;
 echo;
 echo;
 echo +300M;
 echo t;
 echo;
 echo 1;

 echo n;
 echo;
 echo;
 echo +30G;
 echo t;
 echo;
 echo 23;
 
 echo n;
 echo;
 echo;
 echo +1G;
 echo t;
 echo;
 echo 19;

 echo n;
 echo;
 echo;
 echo;
 echo t;
 echo;
 echo 28;
  
 echo w;
) | fdisk /dev/sda


echo 'Ваша разметка диска'
fdisk -l

echo 'Форматирование дисков'
mkfs.fat -F32 /dev/sda1
mkfs.ext4  /dev/sda2
mkswap /dev/sda3
mkfs.ext4  /dev/sda4

echo 'Монтирование дисков'
mount /dev/sda2 /mnt
mkdir /mnt/home
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
mount /dev/sda4 /mnt/home
echo 'Список смонтированных файловых систем.'
lsblk -f

pacman -S reflector && reflector --verbose  -l 5 -p https --sort rate --save /etc/pacman.d/mirrorlist && pacman -Syyu
echo 'Установка основных пакетов'
pacstrap /mnt base base-devel linux linux-firmware nano dhcpcd

echo 'Настройка системы'
genfstab -pU /mnt >> /mnt/etc/fstab

arch-chroot /mnt
pacman -Syy
efibootmgr -d /dev/sda -p 1 -c -L "Arch Linux" -l /vmlinuz-linux -u "root=/dev/sda2 rw initrd=\initramfs-linux.img"
efibootmgr -o 0004
passwd
