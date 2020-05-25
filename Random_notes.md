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

Add-ons:
* uBlock Origin
* Imagus
* Dark Reader
* Stylus
    * [GitHub Dark](https://github.com/StylishThemes/GitHub-Dark)
    * [Dark Wikipedia](https://userstyles.org/styles/42313/dark-wikipedia)
    * [StackOverflow Dark](https://github.com/StylishThemes/StackOverflow-Dark)
    * [A Dark Hacker News](https://userstyles.org/styles/22794/a-dark-hacker-news)
    * [Stylus Dark - ShadowFox](https://userstyles.org/styles/153739/stylus-dark-shadowfox)

## Ghidra

* Edit -> Tool Options -> Tool
    * Swing Look and Feel -> "CDE/Motif"
    * Use Inverted Colors (Enabled)

## Ranger Icons

~/.Xresouces needs to use "Sauce Code Pro":
```
URxvt*font:     xft:SauceCodePro Nerd Font Mono:size=12
URxvt*boldFont: xft:SauceCodePro Nerd Font Mono:size=12
```

Need at minimum this package (AUR): `nerd-fonts-source-code-pro`

Then install ranger_devicons:
```
$ git clone https://github.com/alexanderjeurissen/ranger_devicons
$ cd ranger_devicons/
$ make install
```

## VSCodium

Change font:
* File -> Preferences -> Settings -> Text Editor -> Font -> Font Family -> "Source Code Pro"

Extensions:
* Python
* Go
* Code Spell Checker
