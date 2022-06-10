#!/bin/bash

#########Setup Variables.###############
#Github public sshkeys
github_user="mmccollum2"
#New Username for SSH Access
newuser="applepie"
#Changing the hostname of the pi
hostname="rpi4"

#IP Info to set below  (If you want to set the static ip, then uncomment these, and then uncomment line 117 and 120 for setting and displaying the new ip info)
#ipaddress="0.0.0.0/24"
#gateway="0.0.0.0"
#DNS Servers, put a space between if multiple
#dns="208.67.222.222 1.1.1.1"

#Install xkcdpass for password generation
sudo apt install -y xkcdpass
#########Begin Script###############

#Lock the password for pi since it's default, and we won't be using it anymore
sudo usermod --lock pi
#Create the new ssh only user with no password automatically, and (yes y) hits enter to all the "info"
yes y | sudo adduser ${newuser} --disabled-password
#create random password

###   Other Password generation or default setting
#randompw=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 12 | head -n 1)
#randompw="ApplePie4"

#Generate an xkcdpass, 3 words long, and each word needs to be between a length of 4 and 10 with a dash separator
##   https://linuxcommandlibrary.com/man/xkcdpass
randompw=$(xkcdpass -n 3 --min 4 --max 10 -d -)

#set the new users password to the random above
echo ${newuser}:${randompw} | sudo chpasswd
#display the password so you can put it into lastpass dummy.
echo -e "\nUserID:\n"$newuser "\nhas been created with the following password:     "${randompw}
echo -e "\n"
#I'll just wait here while you do that
read -n1 -r -p "Make note of this password, Press any key to continue..." key


#Add newly created user to the sudoers file since it doesn't have a password to authenticate to sudo anyway. Note - WIP -

#make a backup copy of the sudoers file
sudo cp /etc/sudoers /tmp/sudoers.bak
#add the new user to the sudoers file with no need for future password prompt
echo "$newuser ALL=(ALL) NOPASSWD:ALL" | sudo tee --append /tmp/sudoers.bak

# Check syntax of the backup file to make sure it is correct.
sudo visudo -cf /tmp/sudoers.bak
if [ $? -eq 0 ]; then
  # Replace the sudoers file with the new only if syntax is correct.
sudo cp /tmp/sudoers.bak /etc/sudoers
else
  echo "Could not modify /etc/sudoers file. Please do this manually."
fi

#Update this cow
#rpi-update isn't needed anymore unless required by support. https://www.raspberrypi.org/forums/viewtopic.php?p=916911#p916911
#sudo rpi-update
sudo apt -y update && sudo apt -y upgrade

#Get rid of extra packages we don't need
#sudo apt-get purge --auto-remove scratch debian-reference-en dillo idle3 python3-tk idle python-pygame python-tk lightdm gnome-themes-standard gnome-icon-theme raspberrypi-artwork gvfs-backends gvfs-fuse desktop-base lxpolkit netsurf-gtk zenity xdg-utils mupdf gtk2-engines alsa-utils  lxde lxtask menu-xdg gksu midori xserver-xorg xinit xserver-xorg-video-fbdev libraspberrypi-dev libraspberrypi-doc dbus-x11 libx11-6 libx11-data libx11-xcb1 x11-common x11-utils lxde-icon-theme gconf-service gconf2-common xserver* ^x11 ^libx ^lx samba* -y

#Add a few, plus raspi-config which we convieniently removed from the above list of packages as a dependency?
#sudo apt -y install vim raspi-config dnsutils
sudo apt -y install vim
#Clean up apt
sudo apt-get clean -y && sudo apt-get autoremove -y

#### change the boot to non-gui and console only and expand the filesystem
##  See https://raspberrypi.stackexchange.com/a/66939/8375 for a list of all the raspi-config magic you may want to automate.
#sudo raspi-config nonint do_boot_behaviour B1
#sudo raspi-config nonint is_installed realvnc-vnc-server
#sudo raspi-config nonint do_expand_rootfs
sudo raspi-config nonint do_change_timezone America/Edmonton

#Blow away the default ssh config and recreate one from scratch
sudo rm /etc/ssh/ssh_host_* && sudo dpkg-reconfigure openssh-server

#Create the .ssh folder and the authorized keys
sudo -S -u ${newuser} mkdir /home/${newuser}/.ssh && sudo -S -u ${newuser} touch /home/${newuser}/.ssh/authorized_keys
sudo  -S -u ${newuser} ssh-keygen -t rsa -C "${hostname}" -f "/home/${newuser}/.ssh/id_rsa" -P ""

#### Get SSH keys for authentication from github and put the public key into authorized_keys for the new user we created

echo -e "GET http://github.com HTTP/1.0\n\n" | nc github.com 80 > /dev/null 2>&1
if [ $? -eq 0 ]; then
   sudo -S -u ${newuser} curl -sSL https://github.com/${github_user}.keys >> /home/${newuser}/.ssh/authorized_keys
   echo "Keys installed from gitub.com"
 else
   echo "Won't install ssh keys, github.com couldn't be reached."
 fi

#Will disable password authentication through ssh
sed -i "s|[#]*PasswordAuthentication yes|PasswordAuthentication no|g" /etc/ssh/sshd_config

#One liner for static ip config
#sudo sed -i "$ a\interface eth0\nstatic ip_address=${ipaddress}\nstatic routers=${gateway}\nstatic domain_name_servers=${dns}\n" /etc/dhcpcd.conf

cat /home/${newuser}/.ssh/authorized_keys
#tail -n 5 /etc/dhcpcd.conf
read -n1 -r -p "All done, Press any key to reboot..." key

sudo raspi-config nonint do_hostname "${hostname}"
sudo reboot
