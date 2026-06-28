#!/bin/sh

ip link set eth0 down
ip link set eth1 down
rmmod cds_mac
