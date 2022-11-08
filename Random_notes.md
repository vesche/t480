# t480 Random Notes

This and that...

## Bluetooth

I'm using AirPod Pros with my T480, they work great.

* pacman -S bluez bluez-utils pulseaudio-bluetooth
* pulseaudio -k
* sudo systemctl start bluetooth
* sudo systemctl enable bluetooth
* bluetooth-ctl
    * power on
    * scan on
    * pair <mac>
    * connect <mac>
* Follow instructions [here](https://wiki.archlinux.org/index.php/Bluetooth_headset#Setting_up_auto_connection) to setup auto connect

## Firefox

Fix monospace font:
* Preferences -> Fonts and Colors -> Advanced -> Change Monospace to Source Code Pro -> Uncheck "Allow pages to choose their own fonts, instead of your selections above" -> Ok

Extensions:
* uBlock Origin
* Imagus
* Dark Reader

## Ghidra

* Edit -> Tool Options -> Tool
    * Swing Look and Feel -> "CDE/Motif"
    * Use Inverted Colors (Enabled)

## KVM/QEMU/libvirt

```
$ sudo pacman -S qemu virt-manager libguestfs dnsmasq vde2 bridge-utils ebtables iptables
$ # ^ hit yes on any iptable package replacement warnings
$ sudo systemctl enable libvirtd.service
$ sudo systemctl start libvirtd.service
$ sudo vim /etc/libvirt/libvirtd.conf
$ # unix_sock_group = "libvirt"
$ # unix_sock_rw_perms = "0770"
$ sudo usermod -a -G libvirt user
$ newgrp libvirt # or logout & back in
$ cat br1.xml 
<network>
  <name>br1</name>
  <forward mode='nat'/>
  <bridge name='virbr1' stp='on' delay='0'/>
  <ip address='192.168.69.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.69.128' end='192.168.69.254'/>
    </dhcp>
  </ip>
</network>
$ sudo virsh net-define br1.xml
$ sudo virsh net-start br1
$ sudo virsh net-autostart br1
$ sudo virsh net-list --all
$ brctl show
$ sudo systemctl restart libvirtd.service
$ virt-manager
```

## Ranger Icons

You will need a font that can support these icons. Check out one of the nerd font packages if you don't have a working font.

Then install ranger_devicons:
```
$ git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
$ echo "default_linemode devicons" >> $HOME/.config/ranger/rc.conf
```

## Steam Audio / pavucontrol issue

Some apps in Steam use OpenALsoft and you can't change the audio output in pavucontrol...

Create `~/.alsoftrc`:
```
[pulse]
allow-moves=yes
```

It will fix the problem.

## Urxvt tabbed

Add this to `~/.Xresources`

```
! tabs
URxvt.perl-ext-common: tabbed
URxvt.tabbed.tabbar-fg: 3
URxvt.tabbed.tabbar-bg: 0
URxvt.tabbed.tab-fg: 7
URxvt.tabbed.tab-bg: 0
```

## VSCodium

Change font:
* File -> Preferences -> Settings -> Text Editor -> Font -> Font Family -> "Source Code Pro"

Extensions:
* Python
* Go
* Code Spell Checker


## VLC Streaming (streamlink, etc)

If you attempt to stream using VLC on Arch Linux and get a corrupted stream:

![1](img/stream-scrot.png)

You likely need the [aribb24](https://archlinux.org/packages/extra/x86_64/aribb24/) package: `sudo pacman -S aribb24`

