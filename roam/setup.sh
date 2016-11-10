#!/bin/bash


# Working directory

cd "$(dirname "$0")"


# Permissions

[[ "$(whoami)" != "root" ]] && echo "Please run script as root or sudo." && exit

chmod -x webapp/modules/configuration/iptables.sh


# User Inputs

read -p "Access Point Name :`echo $'\n> '`" -e -i "Raspberry Pi" AP_SSID

read -p "Access Point Password :`echo $'\n> '`" -e -i "raspberry" AP_PASSWORD

read -p "Access Point Interface :`echo $'\n> '`" -e -i "wlan0" AP_INTERFACE

read -p "Adapter Interface :`echo $'\n> '`" -e -i "wlan1" ADAPTER_INTERFACE

read -p "Host Name :`echo $'\n> '`" -e -i "raspberrypi" HOST_NAME

read -p "Local Network Address :`echo $'\n> '`" -e -i "10.0.0" AP_IP

read -p "Application Port :`echo $'\n> '`" -e -i "80" APP_PORT

read -p "Application Name :`echo $'\n> '`" -e -i "Raspberry Pi" APP_NAME

read -p "Connection Process Interval :`echo $'\n> '`" -e -i "2" CONNECTION_INTERVAL


# Installs and Updates

apt-get install unattended-upgrades hostapd dnsmasq python-pip -y

apt-get update -y
apt-get upgrade -y
apt-get autoremove -y


# Python environment

pip install virtualenv
virtualenv .env

.env/bin/pip install -r requirements.txt


# Access Point
# https://gist.github.com/Lewiscowles1986/fecd4de0b45b2029c390

# mv -n -v /etc/systemd/system/hostapd.service /etc/systemd/system/hostapd.service.bak
cat > /etc/systemd/system/hostapd.service <<EOF
[Unit]
Description=Hostapd IEEE 802.11 Access Point
After=sys-subsystem-net-devices-${AP_INTERFACE}.device
BindsTo=sys-subsystem-net-devices-${AP_INTERFACE}.device

[Service]
Type=forking
PIDFile=/var/run/hostapd.pid
ExecStart=/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf -P /var/run/hostapd.pid

[Install]
WantedBy=multi-user.target
EOF

mv -n -v /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
cat > /etc/dnsmasq.conf <<EOF
interface=${AP_INTERFACE}
dhcp-range=${AP_IP}.2,${AP_IP}.5,255.255.255.0,12h
EOF

# mv -n -v /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.bak
cat > /etc/hostapd/hostapd.conf <<EOF
interface=${AP_INTERFACE}
hw_mode=g
channel=10
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=${AP_PASSWORD}
ssid=${AP_SSID}
EOF

mv -n -v /etc/network/interfaces /etc/network/interfaces.bak
cat > /etc/network/interfaces <<EOF
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

iface eth0 inet manual

allow-hotplug ${AP_INTERFACE}
iface ${AP_INTERFACE} inet static
	address ${AP_IP}.1
	netmask 255.255.255.0
	network ${AP_IP}.0
	broadcast ${AP_IP}.255
EOF

mv -n -v /etc/dhcpcd.conf /etc/dhcpcd.conf.bak
cp /etc/dhcpcd.conf.bak /etc/dhcpcd.conf
echo "denyinterfaces ${AP_INTERFACE}" >> /etc/dhcpcd.conf

systemctl enable hostapd


# IP Forward
# https://gist.github.com/Lewiscowles1986/f303d66676340d9aa3cf6ef1b672c0c9

mv -n -v /etc/sysctl.conf /etc/sysctl.conf.bak
cp /etc/sysctl.conf.bak /etc/sysctl.conf
sed -i -- "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/g" /etc/sysctl.conf
sed -i -- "s/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/g" /etc/sysctl.conf

echo 1 > /proc/sys/net/ipv4/ip_forward


# Host Name

mv -n -v /etc/hosts /etc/hosts.bak
cp /etc/hosts.bak /etc/hosts
sed -i -- "s/127.0.1.1.*/127.0.1.1\t${HOST_NAME}/g" /etc/hosts
echo ${HOST_NAME} > /etc/hostname
bash /etc/init.d/hostname.sh


# Application

(crontab -l 2>/dev/null; echo "@reboot sudo $(pwd)/.env/bin/python $(pwd)/webapp --port=${APP_PORT} --name=\"${APP_NAME}\" --ap=${AP_INTERFACE} --adapter=${ADAPTER_INTERFACE} &") | crontab -
(crontab -l 2>/dev/null; echo "*/${CONNECTION_INTERVAL} * * * * sudo $(pwd)/.env/bin/python $(pwd)/webapp/modules/connection.py --ap=${AP_INTERFACE} --adapter=${ADAPTER_INTERFACE} &") | crontab -


echo "Setup complete."


reboot
