#!/bin/bash

# https://gist.github.com/Lewiscowles1986/f303d66676340d9aa3cf6ef1b672c0c9

iptables -t nat -A POSTROUTING -o ${2} -j MASQUERADE
iptables -A FORWARD -i ${2} -o ${1} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${1} -o ${2} -j ACCEPT
