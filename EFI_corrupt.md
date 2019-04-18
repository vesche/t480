# Fixing corrupt EFI partition

Documenting this after RIP 2 hours of my life.

On April 17th I updated the Linux kernel on my T480 from `5.0.5` to `5.0.7`. Upon reboot the system halted before initialization and displayed:
```
Error loading \vmlinuz-linux: Not Found
Failed to execute Arch Linux (\vmlinuz-linux): Not Foud
```

I suspected that the EFI partition was corrupted.

Using a Linux bootable usb, I first tried to use fsck to fix the boot partition:
```bash
fsck.fat -v -a -w /dev/nvme0n1p1 # verbose, auto-correct errors, and write
```

This gave me an error saying that it couldn't seek to the last sector of the partition. AKA fuck me

To recreate my boot partition without burning the house down here's roughly what I did:

```bash
# reformat boot partition
mkfs.fat /dev/nvme0n1p1

# mount root partition
cryptsetup luksOpen /dev/nvme0n1p2 crypted_nvme0n1p2
mount /dev/mapper/main_group-root /mnt

# mount boot partition
mount /dev/nvme0n1p1 /mnt/boot

# chroot
chroot /mnt /bin/bash

# manually mount shit
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs udev /dev

# reinstall linux
sudo pacman -S linux

# reinstall intel-ucode
sudo pacman -S intel-ucode

# rd
mkinitcpio -p linux

# ode to gummiboot
bootctl --path=/boot install

vi /boot/loader/loader.conf  
# default arch
# editor 0

# note nvme0n1p2 uuid
blkid

vi /boot/loader/
# title Arch Linux
# linux /vmlinuz-linux
# initrd /intel-ucode.img
# initrd /initramfs-linux.img
# options cryptdevice=UUID=<UUID_GOES_HERE>:cryptlvm root=/dev/mapper/main_group-root quiet rw

# wrap up
umount /dev
umount /sys
umount /proc
exit
umount -R /mnt
reboot
```