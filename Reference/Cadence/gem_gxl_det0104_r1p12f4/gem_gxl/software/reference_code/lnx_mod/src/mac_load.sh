#!/bin/sh

# NOTE: source this file to keep the following environment:
export PATH=/sbin:/bin
export LOCAL1=192.168.1.1
export REMOTE1=192.168.1.2
export LOCAL2=192.168.2.1
export REMOTE2=192.168.2.2
export ENET1=00:47:45:4d:30:30
export ENET2=00:47:45:4d:30:31

export PATH=/sbin:/bin
# Turn on debug output:
echo 8 > /proc/sys/kernel/printk

modprobe cds_mac $*
ifconfig eth0 ${LOCAL1}
ifconfig eth1 ${LOCAL2}
arp -s ${REMOTE1} ${ENET2}
arp -s ${REMOTE2} ${ENET1}
iptables -t nat -A POSTROUTING -d ${REMOTE1} -j SNAT --to-source ${REMOTE2}
iptables -t nat -A POSTROUTING -d ${REMOTE2} -j SNAT --to-source ${REMOTE1}
iptables -t nat -A PREROUTING -d ${REMOTE2} -j DNAT --to-destination ${LOCAL1}
iptables -t nat -A PREROUTING -d ${REMOTE1} -j DNAT --to-destination ${LOCAL2}
