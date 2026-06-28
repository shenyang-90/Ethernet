#!/bin/sh

ifconfig eth0 down
ifconfig eth1 down
rmmod cds_mac
