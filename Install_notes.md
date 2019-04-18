# t480 Install Guide

* Disable secure boot, reboot.
* On boot hit `Enter` -> `F12` and boot from USB.

GPT:
```
gdisk /dev/nvme0n1
    o
    n
    +256MB (first partition)
    EF00 (EFI)
    n
    ... (use all of disk or partition further)
    8E00 (LVM)
    w
```

LVM:
```
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open --type luks /dev/nvme0n1p2 foo
pvcreate /dev/mapper/foo
vgcreate foo_group /dev/mapper/foo
lvcreate -L32G  foo_group -n swap
lvcreate -L128G foo_group -n root
lvcreate -l 100%FREE foo_group -n home
```

Format:
```
mkfs.fat /dev/nvme0n1p1
mkfs.ext4 /dev/mapper/foo_group-root
mkfs.ext4 /dev/mapper/foo_group-home
mkswap /dev/mapper/foo_group-swap
```

Pre-chroot:
```
mount /dev/mapper/foo_group-root /mnt
mkdir /mnt/home
mount /dev/mapper/foo_group-home /mnt/home
swapon /dev/mapper/foo_group-swap
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
```

chroot:
```
pacstrap -i /mnt base base-devel
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt /bin/bash
```

Setup:
```
vi /etc/locale.gen # uncomment en_US.UTF-8 UTF-8
locale-gen
ln -s /usr/share/zoneinfo/America/Denver /etc/localtime
hwlock --systohc --utc
echo 'hostname' > /etc/hostname
passwd # set root password
vi /etc/pacman.conf # uncomment multilib
vi /etc/pacman.d/mirrorlist # https://www.archlinux.org/mirrorlist/
pacman -S intel-ucode
pacman -S dialog wpa_supplicant # if install on wireless
```

Bootloader:
```
vi /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck)
mkinitcpio -p linux
bootctl --path=/boot install
vi /boot/loader/loader.conf
# default arch
# editor 0
blkid # note UUID
```

vi `/boot/loader/entries/arch.conf`:
```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=<UUID_HERE>:cryptlvm root=/dev/mapper/foo_group-root quiet rw
```

Reboot:
```
exit
unmount -R /mnt
reboot
```

First boot:
```
pacman -S sudo
useradd -m -G wheel -s /bin/bash user
passwd user
visudo # uncomment wheel group
exit # login as user
sudo pacman -S openssh
sudo vi /etc/ssh/sshd_config # change a few things
sudo systemctl enable sshd
sudo systemctl start sshd
```

pacman:
```
pacman -S \
    vim git tree htop python go python-pip scrot acpi \         # util
    rxvt-unicode-terminfo fish tmux \                           # terminal
    nitrogen i3lock \                                           # desktop
    pulseaudio cmus alsa-utils \                                # audio
    vlc streamlink \                                            # video
    net-tools nmap wget tcpdump tcpreplay wireshark-qt \        # networking
    dialog wpa_supplicant \                                     # wireless
    unzip unrar p7zip \                                         # archive
    firefox code gimp libreoffice transmission-qt \             # gui apps
    pcmanfm ranger mupdf radare2 \                              # misc util
    adobe-source-code-pro-fonts noto-fonts \                    # fonts
    xorg-server xorg-xinit xorg-xrandr xf86-video-intel \       # x
    xf86-input-libinput \                                       # touchpad
    bspwm sxhkd dmenu                                           # workflow
```

yay install:
```
mkdir ~/aur && cd ~/aur
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar xzvf yay.tar.gz && cd yay/
makepkg -s
pacman -U yay-*-x86_64.pkg.tar.xz
```

AUR:
```
yay -S \
    rxvt-unicode-patched \          # terminal
    discord spotify polybar \       # applications
    nerd-fonts-source-code-pro \    # font
    slack-desktop zoom              # work
```

CPU throttle:
```
yay -S lenovo-throttling-fix-git
sudo systemctl enable lenovo_fix
sudo systemctl start lenovo_fix
```

Update:
```
sudo pacman -Syyu
```

