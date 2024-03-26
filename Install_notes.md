# t480 Install Guide

No frills Lenovo ThinkPad T480 Arch Linux grab and go.

* Disable secure boot, reboot.
* On boot hit `Enter` -> `F12` and boot from USB.

GPT:
```
gdisk /dev/nvme0n1
    o
    n
    1
    ... (first sector of boot partition)
    +512MB (last sector of boot partition)
    EF00 (EFI)
    n
    2
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
lvcreate -L32G foo_group -n swap
lvcreate -L200G foo_group -n root
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

if not using ethernet:
```
iwctl
    device list
    station wlan0 scan
    station wlan0 get-networks
    station wlan0 connect <SSID>
    exit
```

chroot:
```
pacstrap -i /mnt base base-devel
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt /bin/bash
```

Setup:
```
pacman-key --init
pacman-key --populate archlinux
pacman -Syu vim sudo intel-ucode linux linux-firmware mkinitcpio lvm2 dhcpcd netctl wpa_supplicant dialog
vim /etc/locale.gen # uncomment en_US.UTF-8 UTF-8
locale-gen
ln -s /usr/share/zoneinfo/America/Chicago /etc/localtime
hwclock --systohc --utc
echo hostname > /etc/hostname
passwd # set root password
```

Bootloader:
```
vim /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect keyboard keymap modconf block encrypt lvm2 filesystems fsck)
mkinitcpio -p linux
bootctl --path=/boot install
vim /boot/loader/loader.conf
# default arch
# editor 0
blkid # note UUID of crypto_LUKS drive (primary)
```

vim `/boot/loader/entries/arch.conf`:
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
umount -R /mnt
reboot
```

First boot:
```
useradd -m -G wheel -s /bin/bash user
passwd user
visudo # uncomment wheel group
exit # login as user
```

Ensure locale is set properly:
```
locale
sudo localectl set-locale LANG=en_US.UTF-8
unset LANG
source /etc/profile.d/locale.sh
```

Packages:
```
pacman -S \
    `# archive   ` p7zip zip unzip unrar \
    `# audio     ` pulseaudio pulseaudio-alsa pavucontrol alsa-plugins alsa-utils \
    `# bluetooth ` bluez bluez-utils pulseaudio-bluetooth \
    `# code      ` vim git python python-pip go rust \
    `# desktop   ` nitrogen i3lock \
    `# fonts     ` adobe-source-code-pro-fonts noto-fonts \
    `# gui       ` firefox code vlc obs-studio transmission-qt pcmanfm mupdf geeqie \
    `# misc      ` ranger bind-tools feh tk w3m pdftk boost qt5-xmlpatterns fortune-mod linux-headers \
    `# net       ` net-tools wget tcpdump tcpreplay traceroute nmap wireshark-qt remmina \
    `# re        ` ghidra binwalk \
    `# terminal  ` alacritty fish tmux \
    `# util      ` htop tree scrot acpi cloc whois speedtest-cli ntp strace streamlink croc man-db \
    `# workflow  ` bspwm sxhkd dmenu \
    `# x         ` xorg-server xorg-xinit xorg-xrandr xf86-input-libinput xf86-video-intel
```

yay install:
```
mkdir ~/aur && cd ~/aur
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz
tar xzvf yay.tar.gz && cd yay/
makepkg -s
pacman -U yay-*-x86_64.pkg.tar.zst
```

AUR:
```
yay -S \
    `# bar      ` polybar \
    `# fonts    ` ttf-sourcecodepro-nerd ttf-font-awesome-4 \
    `# gui      ` discord aseprite \  
    `# misc     ` cava s-tui charles ida-free
```

Other tools:
```
# python libraries
pip install --user \
    requests Flask websockets websocket-client beautifulsoup4 \
    twine click crayons bpython numpy Pillow sanic psutil histstat \
    scanless youtube-dl

# edb
sudo git clone --recursive https://github.com/eteran/edb-debugger.git /opt/edb-debugger
cd /opt/edb-debugger
sudo mkdir build
cd build
sudo cmake ..
sudo make
```

Configure fish:
```
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install IlanCosman/tide@v5
set -U fish_greeting ""
fish_add_path ~/.local/bin/
```

CPU throttle:
```
sudo pacman -S throttled
sudo systemctl enable --now lenovo_fix.service
```

dots:
```
git clone https://github.com/vesche/t480 && cd t480/
cp -r dots/.* ~/
cp -r dots/pics ~/
sudo cp dots/bin/* /usr/local/bin/
sudo cp dots/.dialogrc /root/
```

Update:
```
sudo pacman -Syyu
```
