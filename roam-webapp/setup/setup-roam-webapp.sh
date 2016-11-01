#!/bin/bash

[[ "$(whoami)" != "root" ]] && echo "Please run script as root or sudo." && exit


# User Inputs

read -p "Application Port :`echo $'\n> '`" -e -i "80" APP_PORT

read -p "Application Name :`echo $'\n> '`" -e -i "Raspberry Pi" APP_NAME

read -p "Host Name :`echo $'\n> '`" -e -i "raspberrypi" HOST_NAME

read -p "Access Point Interface :`echo $'\n> '`" -e -i "wlan0" AP_INTERFACE

read -p "Adapter Interface :`echo $'\n> '`" -e -i "wlan1" ADAPTER_INTERFACE

read -p "Connection Process Interval :`echo $'\n> '`" -e -i "2" CONNECTION_INTERVAL


# Updates and Installs

apt-get install python-pip -y

pip install virtualenv
virtualenv .env

.env/bin/pip install -r requirements.txt


# Application

(crontab -l 2>/dev/null; echo "@reboot sudo $(pwd)/.env/bin/python $(pwd)/webapp/app.py --port=${APP_PORT} --name="${APP_NAME}" --ap=${AP_INTERFACE} --adapter=${ADAPTER_INTERFACE} &") | crontab -
(crontab -l 2>/dev/null; echo "@reboot sudo $(pwd)/.env/bin/python $(pwd)/setup/connection-process.py --adapter=${ADAPTER_INTERFACE}") | crontab -
(crontab -l 2>/dev/null; echo "*/${CONNECTION_INTERVAL} * * * * sudo $(pwd)/.env/bin/python $(pwd)/setup/connection-process.py --adapter=${ADAPTER_INTERFACE}") | crontab -


# IP Tables

# https://gist.github.com/Lewiscowles1986/f303d66676340d9aa3cf6ef1b672c0c9

mv -n -v /etc/sysctl.conf /etc/sysctl.conf.bak
cp /etc/sysctl.conf.bak /etc/sysctl.conf
sed -i -- "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/g" /etc/sysctl.conf
sed -i -- "s/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/g" /etc/sysctl.conf

echo 1 > /proc/sys/net/ipv4/ip_forward

(crontab -l 2>/dev/null; echo "@reboot sudo bash $(pwd)/setup/iptables-wifi-ap.sh ${AP_INTERFACE} ${ADAPTER_INTERFACE}") | crontab -


# Host Name

mv -n -v /etc/hosts /etc/hosts.bak
cp /etc/hosts.bak /etc/hosts
sed -i -- "s/127.0.1.1.*/127.0.1.1\t${HOST_NAME}/g" /etc/hosts
echo ${HOST_NAME} > /etc/hostname
bash /etc/init.d/hostname.sh


reboot
