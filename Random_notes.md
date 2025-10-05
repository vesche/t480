# t480 Random Notes

This and that...

## Bluetooth

I use Shokz OpenRun Pro 2 Headphones with my T480, they are amazing.

* pacman -S bluez bluez-utils pulseaudio-bluetooth
* pulseaudio -k
* sudo systemctl start bluetooth
* sudo systemctl enable bluetooth
* bluetoothctl
    * `power on`
    * `scan on`
    * `scan off` (when you found the device)
    * `pair <mac>`
    * `connect <mac>`
    * `exit`
* Follow instructions [here](https://wiki.archlinux.org/index.php/Bluetooth_headset#Setting_up_auto_connection) to setup auto connect if you want.

I'm not a huge fan of bluetooth auto connect because I'm paranoid, manual bash script:
```
#!/bin/bash

bluetoothctl connect "<mac_addr>"
polybar -r
```

## LibreWolf / Firefox

Fix monospace font:
* Preferences -> Fonts and Colors -> Advanced -> Change Monospace to Source Code Pro -> Uncheck "Allow pages to choose their own fonts, instead of your selections above" -> Ok

Extensions:
* uBlock Origin
* Imagus
* Dark Reader

## Ghidra

Dark mode:
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

## United Wifi

Documenting this at 35,000 feet because fuck United wifi.

You need to resolve `unitedwifi.com` which doesn't play nice with 3rd party DNS servers and DNS over HTTPS. Queue the- "It's not DNS. There's no fucking way it's DNS. It was DNS." If `unitedwifi.com` is redirecting to `united.com` then you have a DNS issue.

1. Turn off any VPN, proxy, cloudflared, DNS over HTTPS solution, tunneling software, EDR network agent, etc. If you're on some corp machine you might be SOL if you can't disable their security tooling.
2. Ensure DNS server in `/etc/resolv.conf` is set to what the airplane router / DHCP is providing you. In my case the default gateway is `172.19.0.1` and the DNS server IP is `172.18.0.1`. If you're banging your head against the wall and can't get their stupid DNS server IP, sniff DHCP and then force a DHCP rebind (see below).
  - `sudo tcpdump -i <interface> -vvv port 67 or port 68`
  - `sudo dhcpcd --rebind`
  - grep the tcpdump output for `Domain-Name-Server`
  - `sudo echo nameserver <ip> > /etc/resolv.conf`
3. In Firefox, make sure DNS over HTTPS is turned off. Settings -> Privacy & Security -> DNS over HTTPS -> Off
4. Now go to `unitedwifi.com`, buy their shit product, and then turn all of your DNS security back on.

## Weird Hotel Wifi

I'm unsure what router technology does this, but it's somehow possible to hide SSID's from select device signatures. If the SSID is hidden (or just not showing up) in `iwlist` / `wifi-menu` / etc, you can still connect of course- this is fairly straight forward. Get the SSID name from a different device or thru physical means and then connect manually.

```
sudo killall wpa_supplicant
sudo wpa_supplicant -B -i <interface> -c /etc/wpa_supplicant/wpa_supplicant.conf
sudo dhcpcd <interface>
```

`wpa_supplicant.conf`, for example, can look like this if there's no password. Once you connect, if there's a captive portal and your browser doesn't auto detect it, hit `detectportal.firefox.com` from Firefox.

```
network={
	ssid="JWMarriott_Guest"
	key_mgmt=NONE
}
```

If there is a password, do it up like so:

```
network={
	ssid="John's iPhone"
	psk="passwordGoesHere"
}
```

