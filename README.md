# Rpi-Automated
Scripts for the automated deployment of a Raspberry Pi 

#!/bin/bash
#Downsize and prep from standard Raspbian Image
#Tested May 26 2020
#https://www.raspberrypi.org/downloads/raspbian/
#Raspbian Buster Lite
#MacOSX
#diskutil list
#diskutil unmountdisk /dev/disk2
#sudo dd if=2020-02-13-raspbian-buster-lite.img of=/dev/disk2 bs=2m
#Windows - https://sourceforge.net/projects/win32diskimager/files/latest/download?source=navbar
#
#
#Once image is on sd card, create a file called ssh and put it into the boot directory
#Also add a file called wpa_supplicant.conf to the boot directory to have wifi configured on bootup
#wpa_supplicant.conf
#
#ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
#update_config=1
#country=CA
#
#network={
#    ssid="ssidhereee"
#    psk="wifipwdhereee"
#    key_mgmt=WPA-PSK
#}
#
