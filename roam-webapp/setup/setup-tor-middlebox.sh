#!/bin/bash

[[ "$(whoami)" != "root" ]] && echo "Please run script as root or sudo." && exit


# User Inputs

read -p "Local Network Address :`echo $'\n> '`" -e -i "10.0.0" AP_IP


# Updates and Installs

apt-get install tor -y

mv -n -v /etc/tor/torrc /etc/tor/torrc.bak
cat > /etc/tor/torrc <<EOF
Log notice file /var/log/tor/notices.log
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsSuffixes .onion,.exit
AutomapHostsOnResolve 1
TransPort 9040
TransListenAddress ${AP_IP}.1
DNSPort 53
DNSListenAddress ${AP_IP}.1
EOF

touch /var/log/tor/notices.log
chown debian-tor /var/log/tor/notices.log
chmod 644 /var/log/tor/notices.log


echo "Setup complete."
