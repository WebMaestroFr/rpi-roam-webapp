#!/bin/sh

# 1 : Connection Active
# 2 : Access Point Interface
# 3 : Adapter Interface
# 4 : Application IP
# 5 : Application Port

iptables -F
iptables -t nat -F

# if [ ${1} = 1 ]
# then
#     Pi is connected

iptables -A FORWARD -i ${3} -o ${2} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i ${2} -o ${3} -j ACCEPT
iptables -t nat -A POSTROUTING -o ${3} -j MASQUERADE

# else
#     Pi is not connected

#     iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination ${4}:${5}
#     iptables -t nat -A POSTROUTING -j MASQUERADE
#
# fi
