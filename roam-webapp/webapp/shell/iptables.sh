#!/bin/sh

# 1 : Access Point Interface
# 2 : Adapter Interface
# 3 : Connection Active
# 4 : Tor Enabled

iptables -F
iptables -t nat -F

if [ ${3} = 1 ]
then

    if [ ${4} = 1 ]
    then
        iptables -t nat -A PREROUTING -i ${2} -p tcp --dport 22 -j REDIRECT --to-ports 22
        iptables -t nat -A PREROUTING -i ${2} -p udp --dport 53 -j REDIRECT --to-ports 53
        iptables -t nat -A PREROUTING -i ${2} -p tcp --syn -j REDIRECT --to-ports 9040
        sudo service tor start
    else
        sudo service tor stop
    fi

    iptables -t nat -A POSTROUTING -o ${2} -j MASQUERADE
    iptables -A FORWARD -i ${2} -o ${1} -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ${1} -o ${2} -j ACCEPT

else

    # CAPTIVE PORTAL

fi
