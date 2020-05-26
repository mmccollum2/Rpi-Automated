# Automated Raspberry Pi Deployments
* Hardware : Raspberry Pi 4
* Software : Rasbian Buster Lite

### Quick Start

```
wget https://raw.githubusercontent.com/mmccollum2/Rpi-Automated/master/deploy.sh && chmod +x deploy.sh && sudo ./deploy.sh
```

## Images
- https://www.raspberrypi.org/downloads/raspbian/
- Extract the Zip

### MAC OSX Imaging to SD Card

```
diskutil list
diskutil unmountdisk /dev/disk2
sudo dd if=2020-02-13-raspbian-buster-lite.img of=/dev/disk2 bs=2m
```

### Windows Imaging to SD Card
* Download W32DiskImager
https://sourceforge.net/projects/win32diskimager/files/latest/download?source=navbar
* Push the .img to the SD Card

### Prep the SD Card
- Once image is on sd card, create a file called ssh and put it into the boot directory
- Also add a file called wpa_supplicant.conf to the boot directory to have wifi configured on bootup
```
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=CA

network={
    ssid="ssidheree"
    psk="paswdddheree"
    key_mgmt=WPA-PSK
}
```


## Acknowledgments

* I'd like to thank people who do things
* Inspiration here
* hunter2
