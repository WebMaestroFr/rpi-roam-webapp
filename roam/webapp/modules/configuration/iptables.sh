#!/bin/sh

# 1 : Connection Active
# 2 : Access Point Interface
# 3 : Adapter Interface

iptables -F
iptables -t nat -F

if [ ${1} = 1 ]
then
    # Pi is connected

    iptables -t nat -A POSTROUTING -o ${3} -j MASQUERADE
    iptables -A FORWARD -i ${3} -o ${2} -m state --state RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i ${2} -o ${3} -j ACCEPT

# else
    # Pi is not connected

    # TO DO : CAPTIVE PORTAL

fi
