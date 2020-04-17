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
    +256MB (last sector of boot partition)
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
lvcreate -L64G foo_group -n root
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
# connect to internet now (wifi-menu -o OR ethernet)
pacstrap -i /mnt base base-devel
genfstab -U /mnt > /mnt/etc/fstab
arch-chroot /mnt /bin/bash
```

Setup:
```
pacman -S vi sudo intel-ucode linux mkinitcpio lvm2
pacman -S dialog netctl wpa_supplicant dhcpcd # if install on wireless
vi /etc/locale.gen # uncomment en_US.UTF-8 UTF-8
locale-gen
ln -s /usr/share/zoneinfo/America/Denver /etc/localtime
hwclock --systohc --utc
echo 'hostname' > /etc/hostname
passwd # set root password
vi /etc/pacman.conf # uncomment multilib
vi /etc/pacman.d/mirrorlist # https://www.archlinux.org/mirrorlist/
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
blkid # note UUID of crypto_LUKS drive (primary)
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
umount -R /mnt
reboot
```

First boot:
```
useradd -m -G wheel -s /bin/bash user
passwd user
visudo # uncomment wheel group
exit # login as user
sudo pacman -S openssh
sudo vi /etc/ssh/sshd_config # change a few things
sudo systemctl enable sshd
sudo systemctl start sshd
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
    `# audio     ` pulseaudio pavucontrol alsa-utils \
    `# bluetooth ` bluez bluez-utils pulseaudio-bluetooth \
    `# code      ` vim git python python-pip go rust \
    `# desktop   ` nitrogen i3lock \
    `# fonts     ` adobe-source-code-pro-fonts noto-fonts \
    `# gui       ` firefox vlc libreoffice obs-studio gimp transmission-qt pcmanfm mupdf geeqie \
    `# libs      ` linux-headers sdl2 sdl2_net sdl2_image sdl2_mixer sdl2_ttf \
    `# misc      ` ranger bind-tools feh tk w3m pdftk boost qt5-xmlpatterns \
    `# net       ` net-tools wget tcpdump tcpreplay traceroute nmap wireshark-qt remmina \
    `# re        ` ghidra radare2 radare2-cutter r2ghidra-dec binwalk \
    `# terminal  ` rxvt-unicode-terminfo fish tmux \
    `# util      ` htop tree scrot acpi cloc whois speedtest-cli ntp strace streamlink \
    `# wireless  ` dialog wpa_supplicant aircrack-ng \
    `# workflow  ` bspwm sxhkd dmenu \
    `# x         ` xorg-server xorg-xinit xorg-xrandr xf86-input-libinput xf86-video-intel
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
    `# bar      ` polybar \
    `# fonts    ` nerd-fonts-source-code-pro ttf-font-awesome-4
    `# gui      ` vscodium-bin discord spotify android-studio aseprite \  
    `# misc     ` cava s-tui android-apktool charles ida-free \
    `# terminal ` rxvt-unicode-patched \
```

Other tools:
```
# python libraries, add ~/.local/bin to PATH
pip install \
    requests flask websockets websocket-client beautifulsoup4 blessed catt \
    twine click crayons bpython httpx numpy Pillow sanic psutil histstat

# edb
git clone --recursive https://github.com/eteran/edb-debugger.git
    mkdir build
    cd build
    cmake ..
    make
    ./edb

# pwn tools
pip install git+https://github.com/Gallopsled/pwntools.git@dev
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
